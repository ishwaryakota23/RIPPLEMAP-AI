import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api/ripplemap_api.dart';
import 'auth/auth_gate.dart';
import 'auth/ripplemap_auth_service.dart';

void main() {
  runApp(const RippleMapApp());
}

class RippleMapApp extends StatelessWidget {
  const RippleMapApp({super.key, this.authService});

  final RippleMapAuthService? authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RippleMap AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B18),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C6CFF),
          secondary: Color(0xFF30D7E8),
          surface: Color(0xFF10172A),
          error: Color(0xFFFF657A),
        ),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: AuthGate(
        authService: authService ?? RippleMapAuthService(),
        dashboardBuilder: (onLogout) => DashboardPage(onLogout: onLogout),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _api = RippleMapApi();
  Map<String, dynamic>? _configuration;
  List<Map<String, dynamic>> _repositories = const [];
  List<Map<String, dynamic>> _pullRequests = const [];
  List<Map<String, dynamic>> _analysisHistory = const [];
  Map<String, dynamic>? _analysis;
  String? _selectedRepository;
  int? _selectedPullRequest;
  String? _reviewDecision;
  String? _reviewNote;
  String? _error;
  bool _loading = true;
  bool _analyzing = false;
  int _navigationIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final config = await _api.getConfiguration();
      final repos = config['githubConnected'] == true
          ? await _api.getRepositories()
          : <Map<String, dynamic>>[];
      final settings = await _api.getUserSettings();
      final history = await _api.getAnalysisHistory();
      final preferredRepository = settings['selectedRepository'] as String?;
      final selectedRepository = repos.cast<Map<String, dynamic>?>().firstWhere(
        (repository) =>
            '${repository?['owner']}/${repository?['name']}' ==
            preferredRepository,
        orElse: () => repos.isEmpty ? null : repos.first,
      );
      if (!mounted) return;
      setState(() {
        _configuration = config;
        _repositories = repos;
        _analysisHistory = history;
        _loading = false;
      });
      if (selectedRepository != null) {
        await _selectRepository(selectedRepository, persist: false);
      }
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _selectRepository(
    Map<String, dynamic> repository, {
    bool persist = true,
  }) async {
    final owner = repository['owner'] as String?;
    final name = repository['name'] as String?;
    if (owner == null || name == null) return;
    setState(() {
      _selectedRepository = '$owner/$name';
      _selectedPullRequest = null;
      _pullRequests = const [];
      _analysis = null;
      _reviewDecision = null;
      _reviewNote = null;
      _error = null;
    });
    try {
      if (persist) await _api.saveSelectedRepository('$owner/$name');
      final pullRequests = await _api.getPullRequests(owner, name);
      if (!mounted) return;
      setState(() {
        _pullRequests = pullRequests;
        if (pullRequests.isNotEmpty) {
          _selectedPullRequest = pullRequests.first['number'] as int?;
        }
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _connectGitHub() async {
    try {
      await launchUrl(_api.connectUri, webOnlyWindowName: '_self');
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not open GitHub authorization: $error');
    }
  }

  Future<void> _disconnectGitHub() async {
    try {
      await _api.disconnectGitHub();
      await _loadDashboard();
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _analyze() async {
    final repository = _selectedRepository?.split('/');
    final pullRequestNumber = _selectedPullRequest;
    if (repository == null ||
        repository.length != 2 ||
        pullRequestNumber == null) {
      setState(() => _error = 'Choose a repository and pull request first.');
      return;
    }

    setState(() {
      _analyzing = true;
      _error = null;
      _analysis = null;
      _reviewDecision = null;
      _reviewNote = null;
    });
    try {
      var result = await _api.startAnalysis(
        repository[0],
        repository[1],
        pullRequestNumber,
      );
      final id = result['id'] as String?;
      if (id == null) {
        throw const FormatException(
          'The analysis response did not contain an ID.',
        );
      }
      while (result['status'] == 'queued' || result['status'] == 'running') {
        await Future<void>.delayed(const Duration(seconds: 2));
        result = await _api.getAnalysis(id);
        if (!mounted) return;
      }
      if (result['status'] == 'failed') {
        throw Exception(result['error'] as String? ?? 'Analysis failed.');
      }
      if (!mounted) return;
      setState(() {
        _analysis = result;
        _analyzing = false;
      });
      await _loadAnalysisHistory();
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _analyzing = false;
      });
    }
  }

  Future<void> _loadAnalysisHistory() async {
    final history = await _api.getAnalysisHistory();
    if (!mounted) return;
    setState(() => _analysisHistory = history);
  }

  Future<void> _openHistoricalAnalysis(Map<String, dynamic> item) async {
    final id = item['id'] as String?;
    if (id == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _navigationIndex = 1;
    });
    try {
      final analysis = await _api.getAnalysis(id);
      if (!mounted) return;
      setState(() {
        _analysis = analysis;
        _reviewDecision = analysis['reviewDecision'] as String?;
        _reviewNote = analysis['reviewNote'] as String?;
        _loading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _saveReview(String decision) async {
    final id = _analysis?['id'] as String?;
    if (id == null) {
      setState(() => _error = 'This analysis cannot be reviewed yet.');
      return;
    }
    try {
      final review = await _api.saveAnalysisReview(
        id,
        decision: decision,
        note: _reviewNote,
      );
      if (!mounted) return;
      setState(() {
        _reviewDecision = review['decision'] as String?;
        _reviewNote = review['note'] as String?;
        _error = null;
      });
      await _loadAnalysisHistory();
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (!compact)
                  _Sidebar(
                    selectedIndex: _navigationIndex,
                    onSelected: (index) =>
                        setState(() => _navigationIndex = index),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(
                        compact: compact,
                        connected: _configuration?['githubConnected'] == true,
                        onConnect: _connectGitHub,
                        onLogout: widget.onLogout,
                      ),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildContent(compact),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: compact
              ? NavigationBar(
                  selectedIndex: _navigationIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _navigationIndex = index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      label: 'Overview',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.account_tree_outlined),
                      label: 'Analyze',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      label: 'Settings',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history_rounded),
                      label: 'History',
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildContent(bool compact) {
    if (_navigationIndex == 2) {
      return _SettingsContent(
        configuration: _configuration,
        selectedRepository: _selectedRepository,
        onDisconnectGitHub: _disconnectGitHub,
      );
    }
    if (_navigationIndex == 3) {
      return _AnalysisHistoryContent(
        items: _analysisHistory,
        onRefresh: _loadAnalysisHistory,
        onSelected: _openHistoricalAnalysis,
      );
    }
    return _DashboardContent(
      compact: compact,
      connected: _configuration?['githubConnected'] == true,
      configuration: _configuration,
      repositories: _repositories,
      pullRequests: _pullRequests,
      selectedRepository: _selectedRepository,
      selectedPullRequest: _selectedPullRequest,
      analysis: _analysis,
      error: _error,
      analyzing: _analyzing,
      onConnect: _connectGitHub,
      onRefresh: _loadDashboard,
      onRepositoryChanged: _selectRepository,
      onPullRequestChanged: (number) =>
          setState(() => _selectedPullRequest = number),
      onAnalyze: _analyze,
      reviewDecision: _reviewDecision,
      reviewNote: _reviewNote,
      onReview: _saveReview,
      onReviewNoteChanged: (note) => setState(() => _reviewNote = note),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.compact,
    required this.connected,
    required this.onConnect,
    required this.onLogout,
  });

  final bool compact;
  final bool connected;
  final VoidCallback onConnect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 32),
      decoration: const BoxDecoration(
        color: Color(0xFF090E1D),
        border: Border(bottom: BorderSide(color: Color(0xFF1C2740))),
      ),
      child: Row(
        children: [
          if (compact) ...[
            const _BrandMark(size: 34),
            const SizedBox(width: 10),
            const Text(
              'RippleMap',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const Spacer(),
            _StatusPill(
              label: connected ? 'Connected' : 'Connect GitHub',
              active: connected,
              onTap: connected ? null : onConnect,
            ),
            IconButton(
              onPressed: onLogout,
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout, size: 19),
            ),
          ] else ...[
            const Spacer(),
            const Icon(Icons.search, size: 18, color: Color(0xFF8490AA)),
            const SizedBox(width: 10),
            const Text(
              'Repository impact intelligence',
              style: TextStyle(color: Color(0xFF91A0BA), fontSize: 13),
            ),
            const SizedBox(width: 22),
            _StatusPill(
              label: connected ? 'GitHub connected' : 'Connect GitHub',
              active: connected,
              onTap: connected ? null : onConnect,
            ),
            const SizedBox(width: 22),
            const CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFF202B48),
              child: Icon(
                Icons.person_outline,
                size: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Sign out'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 244,
      decoration: const BoxDecoration(
        color: Color(0xFF090E1D),
        border: Border(right: BorderSide(color: Color(0xFF1C2740))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 16, 34),
            child: Row(
              children: [
                const _BrandMark(size: 40),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        children: [
                          TextSpan(text: 'RippleMap '),
                          TextSpan(
                            text: 'AI',
                            style: TextStyle(color: Color(0xFF7488FF)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'IMPACT INTELLIGENCE',
                      style: TextStyle(
                        color: Color(0xFF7D8BA5),
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const _NavLabel('WORKSPACE'),
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'Overview',
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
          _NavItem(
            icon: Icons.account_tree_outlined,
            label: 'Analyze changes',
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
          ),
          _NavItem(
            icon: Icons.history_rounded,
            label: 'Analysis history',
            selected: selectedIndex == 3,
            onTap: () => onSelected(3),
          ),
          const SizedBox(height: 26),
          const _NavLabel('PREFERENCES'),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            selected: selectedIndex == 2,
            onTap: () => onSelected(2),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF10182B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF253353)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF42D6C5), size: 19),
                SizedBox(height: 10),
                Text(
                  'Evidence, not guesswork',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                SizedBox(height: 5),
                Text(
                  'Every impact links back to repository evidence.',
                  style: TextStyle(
                    color: Color(0xFF93A1BA),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.compact,
    required this.connected,
    required this.configuration,
    required this.repositories,
    required this.pullRequests,
    required this.selectedRepository,
    required this.selectedPullRequest,
    required this.analysis,
    required this.error,
    required this.analyzing,
    required this.onConnect,
    required this.onRefresh,
    required this.onRepositoryChanged,
    required this.onPullRequestChanged,
    required this.onAnalyze,
    required this.reviewDecision,
    required this.reviewNote,
    required this.onReview,
    required this.onReviewNoteChanged,
  });

  final bool compact;
  final bool connected;
  final Map<String, dynamic>? configuration;
  final List<Map<String, dynamic>> repositories;
  final List<Map<String, dynamic>> pullRequests;
  final String? selectedRepository;
  final int? selectedPullRequest;
  final Map<String, dynamic>? analysis;
  final String? error;
  final bool analyzing;
  final VoidCallback onConnect;
  final VoidCallback onRefresh;
  final ValueChanged<Map<String, dynamic>> onRepositoryChanged;
  final ValueChanged<int?> onPullRequestChanged;
  final VoidCallback onAnalyze;
  final String? reviewDecision;
  final String? reviewNote;
  final ValueChanged<String> onReview;
  final ValueChanged<String?> onReviewNoteChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 34,
        28,
        compact ? 16 : 34,
        36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHANGE IMPACT',
                          style: TextStyle(
                            color: Color(0xFF8A9BB8),
                            fontSize: 10,
                            letterSpacing: 1.7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'See the impact before the breakage.',
                          style: TextStyle(
                            fontSize: compact ? 23 : 30,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Understand code changes, dependency reach, and risk before merge.',
                          style: TextStyle(
                            color: Color(0xFF9CAAC1),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!compact)
                    OutlinedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh, size: 17),
                      label: const Text('Refresh'),
                    ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 20),
                _Notice(message: error!, isError: true),
              ],
              const SizedBox(height: 26),
              if (!connected)
                _ConnectCard(
                  compact: compact,
                  configured: configuration?['githubConfigured'] == true,
                  onConnect: onConnect,
                )
              else ...[
                _AnalysisSelector(
                  compact: compact,
                  repositories: repositories,
                  pullRequests: pullRequests,
                  selectedRepository: selectedRepository,
                  selectedPullRequest: selectedPullRequest,
                  onRepositoryChanged: onRepositoryChanged,
                  onPullRequestChanged: onPullRequestChanged,
                  onAnalyze: onAnalyze,
                  analyzing: analyzing,
                ),
                const SizedBox(height: 18),
                _MetricRow(
                  compact: compact,
                  analysis: analysis,
                  analyzing: analyzing,
                ),
                const SizedBox(height: 18),
                if (analysis == null)
                  _EmptyAnalysis(analyzing: analyzing)
                else
                  _AnalysisResults(
                    analysis: analysis!,
                    compact: compact,
                    reviewDecision: reviewDecision,
                    reviewNote: reviewNote,
                    onReview: onReview,
                    onReviewNoteChanged: onReviewNoteChanged,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectCard extends StatelessWidget {
  const _ConnectCard({
    required this.compact,
    required this.configured,
    required this.onConnect,
  });

  final bool compact;
  final bool configured;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect your GitHub repository',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          configured
              ? 'Authorize read access to select repositories and pull requests.'
              : 'GitHub OAuth is not configured on the Serverpod backend yet.',
          style: const TextStyle(
            color: Color(0xFF9CAAC1),
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
    final button = FilledButton.icon(
      onPressed: configured ? onConnect : null,
      icon: const Icon(Icons.link, size: 17),
      label: Text(configured ? 'Connect GitHub' : 'Setup required'),
    );
    return _Panel(
      padding: EdgeInsets.all(compact ? 20 : 28),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171E37),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.hub_outlined,
                        color: Color(0xFF9B8AFF),
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: content),
                  ],
                ),
                const SizedBox(height: 18),
                button,
              ],
            )
          : Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF171E37),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.hub_outlined,
                    color: Color(0xFF9B8AFF),
                    size: 27,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(child: content),
                const SizedBox(width: 16),
                button,
              ],
            ),
    );
  }
}

class _AnalysisSelector extends StatelessWidget {
  const _AnalysisSelector({
    required this.compact,
    required this.repositories,
    required this.pullRequests,
    required this.selectedRepository,
    required this.selectedPullRequest,
    required this.onRepositoryChanged,
    required this.onPullRequestChanged,
    required this.onAnalyze,
    required this.analyzing,
  });

  final bool compact;
  final List<Map<String, dynamic>> repositories;
  final List<Map<String, dynamic>> pullRequests;
  final String? selectedRepository;
  final int? selectedPullRequest;
  final ValueChanged<Map<String, dynamic>> onRepositoryChanged;
  final ValueChanged<int?> onPullRequestChanged;
  final VoidCallback onAnalyze;
  final bool analyzing;

  @override
  Widget build(BuildContext context) {
    final repositoryOptions = repositories
        .map(
          (repository) => DropdownMenuItem<String>(
            value: '${repository['owner']}/${repository['name']}',
            child: Text(
              '${repository['owner']}/${repository['name']}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();
    final prOptions = pullRequests
        .map(
          (pr) => DropdownMenuItem<int>(
            value: pr['number'] as int,
            child: Text(
              '#${pr['number']}  ${pr['title']}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 14,
        runSpacing: 14,
        children: [
          const _SectionLabel(
            icon: Icons.account_tree_outlined,
            text: 'ANALYZE A CHANGE',
          ),
          SizedBox(
            width: compact ? double.infinity : 260,
            child: DropdownButtonFormField<String>(
              initialValue: selectedRepository,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Repository'),
              items: repositoryOptions,
              onChanged: (value) {
                final repository = repositories
                    .cast<Map<String, dynamic>?>()
                    .firstWhere(
                      (item) => '${item?['owner']}/${item?['name']}' == value,
                      orElse: () => null,
                    );
                if (repository != null) onRepositoryChanged(repository);
              },
            ),
          ),
          SizedBox(
            width: compact ? double.infinity : 360,
            child: DropdownButtonFormField<int>(
              initialValue: selectedPullRequest,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Pull request'),
              items: prOptions,
              onChanged: onPullRequestChanged,
              hint: const Text('Select a pull request'),
            ),
          ),
          FilledButton.icon(
            onPressed: analyzing ? null : onAnalyze,
            icon: analyzing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bolt, size: 18),
            label: Text(analyzing ? 'Analyzing…' : 'Analyze impact'),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.compact,
    required this.analysis,
    required this.analyzing,
  });

  final bool compact;
  final Map<String, dynamic>? analysis;
  final bool analyzing;

  @override
  Widget build(BuildContext context) {
    final changedFiles = _resultList(analysis, 'changedFiles').length;
    final direct = _resultList(analysis, 'directImpacts').length;
    final indirect = _resultList(analysis, 'potentialImpacts').length;
    final risk = analysis?['riskLevel'] as String?;
    final metrics = [
      _MetricData(
        'Changed files',
        analysis == null ? '—' : '$changedFiles',
        Icons.edit_note_outlined,
        const Color(0xFF7E8FFF),
      ),
      _MetricData(
        'Directly affected',
        analysis == null ? '—' : '$direct',
        Icons.bolt_outlined,
        const Color(0xFFFFB454),
      ),
      _MetricData(
        'Potential impact',
        analysis == null ? '—' : '$indirect',
        Icons.hub_outlined,
        const Color(0xFF34D4E2),
      ),
      _MetricData(
        'Overall risk',
        risk ?? '—',
        Icons.shield_outlined,
        risk == null ? const Color(0xFF9D8AFF) : _riskColor(risk),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: compact ? 1.85 : 2.05,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: metrics
              .map((metric) => _MetricCard(metric: metric, loading: analyzing))
              .toList(),
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric, required this.loading});
  final _MetricData metric;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(metric.icon, size: 18, color: metric.color),
              const Spacer(),
              if (loading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: metric.value.length > 7 ? 17 : 22,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                metric.label,
                style: const TextStyle(color: Color(0xFF94A3BB), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyAnalysis extends StatelessWidget {
  const _EmptyAnalysis({required this.analyzing});
  final bool analyzing;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(30),
      child: Row(
        children: [
          const Icon(Icons.query_stats, color: Color(0xFF7284FF), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              analyzing
                  ? 'Fetching the pull request diff and tracing repository dependencies…'
                  : 'Select a pull request and run an analysis to see evidence-backed impact.',
              style: const TextStyle(color: Color(0xFFACB8CD), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisResults extends StatelessWidget {
  const _AnalysisResults({
    required this.analysis,
    required this.compact,
    required this.reviewDecision,
    required this.reviewNote,
    required this.onReview,
    required this.onReviewNoteChanged,
  });

  final Map<String, dynamic> analysis;
  final bool compact;
  final String? reviewDecision;
  final String? reviewNote;
  final ValueChanged<String> onReview;
  final ValueChanged<String?> onReviewNoteChanged;

  @override
  Widget build(BuildContext context) {
    final changedFiles = _resultList(analysis, 'changedFiles');
    final direct = _resultList(analysis, 'directImpacts');
    final potential = _resultList(analysis, 'potentialImpacts');
    final recommendations = _resultList(analysis, 'recommendations');
    final aiStatus = analysis['aiStatus'] as String? ?? 'unavailable';
    final aiInsights = _resultList(analysis, 'aiInsights');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            SizedBox(
              width: compact ? double.infinity : 420,
              child: _Panel(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(
                      icon: Icons.account_tree_outlined,
                      text: 'DEPENDENCY MAP',
                    ),
                    const SizedBox(height: 16),
                    _DependencyGraph(
                      changedFiles: changedFiles,
                      directImpacts: direct,
                      potentialImpacts: potential,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Arrows point from a file to the modules it imports.',
                      style: TextStyle(color: Color(0xFF8998B2), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: compact ? double.infinity : 420,
              child: _Panel(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(
                      icon: Icons.warning_amber_rounded,
                      text: 'IMPACT FINDINGS',
                    ),
                    const SizedBox(height: 12),
                    _FindingList(
                      title: 'Confirmed dependencies',
                      items: direct,
                      kind: 'confirmed',
                    ),
                    const SizedBox(height: 10),
                    _FindingList(
                      title: 'Potential impact',
                      items: potential,
                      kind: 'potential',
                    ),
                    if (direct.isEmpty && potential.isEmpty)
                      const _SmallEmpty(
                        'No affected consumers found in supported source files.',
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: compact ? double.infinity : 420,
              child: _Panel(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(
                      icon: Icons.auto_awesome_outlined,
                      text: aiStatus == 'available'
                          ? 'GROQ INSIGHTS'
                          : 'AI INSIGHTS',
                    ),
                    const SizedBox(height: 12),
                    if (aiStatus != 'available')
                      const _SmallEmpty(
                        'AI explanations are unavailable. Deterministic findings remain available.',
                      )
                    else if (aiInsights.isEmpty)
                      const _SmallEmpty(
                        'Groq did not return validated insights for this change.',
                      )
                    else
                      ...aiInsights.map(
                        (item) => _EvidenceBullet(
                          text: item['text'] as String? ?? '$item',
                          color: const Color(0xFF9A8CFF),
                        ),
                      ),
                    if (analysis['aiUnavailableReason'] is String)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          analysis['aiUnavailableReason'] as String,
                          style: const TextStyle(
                            color: Color(0xFF8E9CB4),
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: compact ? double.infinity : 420,
              child: _Panel(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(
                      icon: Icons.checklist_rtl,
                      text: 'NEXT STEPS',
                    ),
                    const SizedBox(height: 12),
                    if (recommendations.isEmpty)
                      const _SmallEmpty(
                        'No test recommendations were found in the available evidence.',
                      )
                    else
                      ...recommendations.map(
                        (item) => _EvidenceBullet(
                          text: item['text'] as String? ?? '$item',
                          color: const Color(0xFF38D7B0),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ChangedFilesPanel(files: changedFiles),
        const SizedBox(height: 14),
        _ReviewDecisionPanel(
          decision: reviewDecision,
          note: reviewNote,
          onReview: onReview,
          onNoteChanged: onReviewNoteChanged,
        ),
        if (analysis['limitations'] is List) ...[
          const SizedBox(height: 14),
          _LimitationsPanel(items: _resultList(analysis, 'limitations')),
        ],
      ],
    );
  }
}

class _ReviewDecisionPanel extends StatelessWidget {
  const _ReviewDecisionPanel({
    required this.decision,
    required this.note,
    required this.onReview,
    required this.onNoteChanged,
  });

  final String? decision;
  final String? note;
  final ValueChanged<String> onReview;
  final ValueChanged<String?> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    final label = switch (decision) {
      'approved' => 'Approved',
      'changes_requested' => 'Changes requested',
      'reviewed' => 'Reviewed',
      _ => 'No review decision saved',
    };
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
            icon: Icons.rate_review_outlined,
            text: 'REVIEW DECISION',
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Color(0xFFAFBCD2))),
          const SizedBox(height: 10),
          TextFormField(
            key: ValueKey(note),
            initialValue: note,
            maxLength: 2000,
            maxLines: 3,
            minLines: 1,
            onChanged: onNoteChanged,
            decoration: const InputDecoration(
              labelText: 'Review note (optional)',
              alignLabelWithHint: true,
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: () => onReview('reviewed'),
                child: const Text('Mark reviewed'),
              ),
              OutlinedButton(
                onPressed: () => onReview('changes_requested'),
                child: const Text('Request changes'),
              ),
              FilledButton.tonal(
                onPressed: () => onReview('approved'),
                child: const Text('Approve'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DependencyGraph extends StatelessWidget {
  const _DependencyGraph({
    required this.changedFiles,
    required this.directImpacts,
    required this.potentialImpacts,
  });

  final List<Map<String, dynamic>> changedFiles;
  final List<Map<String, dynamic>> directImpacts;
  final List<Map<String, dynamic>> potentialImpacts;

  @override
  Widget build(BuildContext context) {
    final root = changedFiles.isEmpty
        ? 'Changed source'
        : changedFiles.first['path'] as String? ?? 'Changed source';
    final consumers = [
      ...directImpacts
          .take(3)
          .map(
            (item) => (
              item['path'] as String? ?? 'consumer',
              const Color(0xFF37D4C8),
            ),
          ),
      ...potentialImpacts
          .take(2)
          .map(
            (item) => (
              item['path'] as String? ?? 'potential',
              const Color(0xFFFFB454),
            ),
          ),
    ];
    if (consumers.isEmpty) {
      return _GraphNode(
        label: root,
        color: const Color(0xFF756BFF),
        highlighted: true,
      );
    }
    return Column(
      children: [
        _GraphNode(
          label: root,
          color: const Color(0xFF756BFF),
          highlighted: true,
        ),
        const SizedBox(height: 5),
        const Icon(Icons.south, color: Color(0xFF65718D), size: 17),
        const SizedBox(height: 5),
        for (final consumer in consumers) ...[
          _GraphNode(label: consumer.$1, color: consumer.$2),
          const SizedBox(height: 7),
        ],
        if (directImpacts.length + potentialImpacts.length > consumers.length)
          Text(
            '+ ${directImpacts.length + potentialImpacts.length - consumers.length} more findings',
            style: const TextStyle(color: Color(0xFF8B9AB4), fontSize: 10),
          ),
      ],
    );
  }
}

class _GraphNode extends StatelessWidget {
  const _GraphNode({
    required this.label,
    required this.color,
    this.highlighted = false,
  });

  final String label;
  final Color color;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: highlighted ? 0.15 : 0.07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withValues(alpha: highlighted ? 0.65 : 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
            ),
          ),
          if (highlighted)
            const Text(
              'CHANGED',
              style: TextStyle(
                fontSize: 8,
                color: Color(0xFFA99DFF),
                letterSpacing: 0.8,
              ),
            ),
        ],
      ),
    );
  }
}

class _FindingList extends StatelessWidget {
  const _FindingList({
    required this.title,
    required this.items,
    required this.kind,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final String kind;

  @override
  Widget build(BuildContext context) {
    final color = kind == 'confirmed'
        ? const Color(0xFF3DD6C7)
        : const Color(0xFFFFB454);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const Spacer(),
            Text(
              '${items.length}',
              style: const TextStyle(color: Color(0xFF94A3BB), fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items
            .take(5)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['path'] as String? ?? 'Unknown file',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                    if (item['reason'] is String)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          item['reason'] as String,
                          style: const TextStyle(
                            color: Color(0xFF8E9CB4),
                            fontSize: 10,
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _ChangedFilesPanel extends StatelessWidget {
  const _ChangedFilesPanel({required this.files});
  final List<Map<String, dynamic>> files;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            icon: Icons.difference_outlined,
            text: 'CHANGED FILES',
            trailing: '${files.length} from pull request',
          ),
          const SizedBox(height: 14),
          if (files.isEmpty)
            const _SmallEmpty(
              'No changed-file diff is available for this pull request.',
            )
          else
            ...files.map((file) {
              final patch = file['patch'] as String? ?? '';
              return ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                leading: Icon(
                  _changeIcon(file['status'] as String?),
                  size: 17,
                  color: const Color(0xFF7F91FF),
                ),
                title: Text(
                  file['path'] as String? ?? 'Unknown file',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
                subtitle: Text(
                  '${file['status'] ?? 'modified'}  ·  '
                  '+${file['additions'] ?? 0}  −${file['deletions'] ?? 0}',
                  style: const TextStyle(
                    color: Color(0xFF91A0B8),
                    fontSize: 10,
                  ),
                ),
                children: [
                  if (patch.isEmpty)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'GitHub did not provide a patch for this file.',
                        style: TextStyle(
                          color: Color(0xFF93A1B8),
                          fontSize: 11,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 360),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF090E1B),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText.rich(
                          TextSpan(
                            children: patch.split('\n').map((line) {
                              final color = line.startsWith('+')
                                  ? const Color(0xFF8BE8C6)
                                  : line.startsWith('-')
                                  ? const Color(0xFFFF9DA9)
                                  : line.startsWith('@@')
                                  ? const Color(0xFF8D9DFF)
                                  : const Color(0xFFBCC6D8);
                              return TextSpan(
                                text: '$line\n',
                                style: TextStyle(
                                  color: color,
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  height: 1.5,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _LimitationsPanel extends StatelessWidget {
  const _LimitationsPanel({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
            icon: Icons.info_outline,
            text: 'SCOPE & UNCERTAINTY',
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => _EvidenceBullet(
              text: item['text'] as String? ?? '$item',
              color: const Color(0xFF8FA2C4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.configuration,
    required this.selectedRepository,
    required this.onDisconnectGitHub,
  });

  final Map<String, dynamic>? configuration;
  final String? selectedRepository;
  final VoidCallback onDisconnectGitHub;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _Panel(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workspace settings',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Secrets are configured on the Serverpod backend and are never sent to the browser.',
                  style: TextStyle(color: Color(0xFF9CAAC1), height: 1.5),
                ),
                const SizedBox(height: 22),
                _SettingRow(
                  label: 'Default repository',
                  value: selectedRepository ?? 'Not selected',
                  okay: selectedRepository != null,
                ),
                if (configuration?['githubConnected'] == true)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onDisconnectGitHub,
                      icon: const Icon(Icons.link_off_outlined),
                      label: const Text('Disconnect GitHub'),
                    ),
                  ),
                _SettingRow(
                  label: 'GitHub OAuth',
                  value: configuration?['githubConfigured'] == true
                      ? 'Configured'
                      : 'Needs setup',
                  okay: configuration?['githubConfigured'] == true,
                ),
                _SettingRow(
                  label: 'Groq AI',
                  value: configuration?['groqConfigured'] == true
                      ? 'Configured'
                      : 'Unavailable — deterministic analysis remains enabled',
                  okay: configuration?['groqConfigured'] == true,
                ),
                const _SettingRow(
                  label: 'Supported languages',
                  value: 'JavaScript and TypeScript',
                  okay: true,
                ),
                const _SettingRow(
                  label: 'Dependency edge direction',
                  value: 'Importer → imported module',
                  okay: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalysisHistoryContent extends StatelessWidget {
  const _AnalysisHistoryContent({
    required this.items,
    required this.onRefresh,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> items;
  final VoidCallback onRefresh;
  final ValueChanged<Map<String, dynamic>> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _Panel(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Analysis history',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onRefresh,
                      tooltip: 'Refresh analysis history',
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your most recent 100 analyses and saved review decisions.',
                  style: TextStyle(color: Color(0xFF9CAAC1)),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const _SmallEmpty(
                    'No analyses yet. Connect GitHub and analyze a pull request to build your history.',
                  )
                else
                  ...items.map((item) {
                    final id = item['id'] as String?;
                    final status = item['status'] as String? ?? 'unknown';
                    final review = item['reviewDecision'] as String?;
                    final createdAt = DateTime.tryParse(
                      item['createdAt'] as String? ?? '',
                    );
                    final subtitle = [
                      '${item['owner']}/${item['repository']}  #${item['pullRequestNumber']}',
                      status,
                      if (review != null)
                        'Review: ${review.replaceAll('_', ' ')}',
                      if (createdAt != null)
                        createdAt.toLocal().toString().split('.').first,
                    ].join('  ·  ');
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        status == 'completed'
                            ? Icons.check_circle_outline
                            : status == 'failed'
                            ? Icons.error_outline
                            : Icons.hourglass_empty,
                        color: status == 'completed'
                            ? const Color(0xFF43D5B4)
                            : status == 'failed'
                            ? const Color(0xFFFF7589)
                            : const Color(0xFFFFC46C),
                      ),
                      title: Text(
                        '${item['owner']}/${item['repository']}  #${item['pullRequestNumber']}',
                      ),
                      subtitle: Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF96A4BC)),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: status == 'completed' && id != null
                          ? () => onSelected(item)
                          : null,
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.okay,
  });

  final String label;
  final String value;
  final bool okay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF27324A))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 14),
          Icon(
            okay ? Icons.check_circle_outline : Icons.info_outline,
            size: 16,
            color: okay ? const Color(0xFF43D5B4) : const Color(0xFFFFB454),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF9CAAC1), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.active, this.onTap});

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        active ? Icons.check_circle_outline : Icons.add_link,
        size: 15,
        color: active ? const Color(0xFF46D6B8) : const Color(0xFFA99AFF),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF80E2CB) : const Color(0xFFC1B8FF),
          fontSize: 11,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        backgroundColor: active
            ? const Color(0xFF102A2B)
            : const Color(0xFF1B1A36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BrandPainter()),
    );
  }
}

class _BrandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(size.width * .5, size.height * .08),
      Offset(size.width * .18, size.height * .32),
      Offset(size.width * .82, size.height * .34),
      Offset(size.width * .28, size.height * .8),
      Offset(size.width * .74, size.height * .78),
      Offset(size.width * .5, size.height * .49),
    ];
    final line = Paint()
      ..color = const Color(0xFF6879FF)
      ..strokeWidth = size.width * .045
      ..style = PaintingStyle.stroke;
    for (final (a, b) in [
      (0, 1),
      (0, 2),
      (1, 5),
      (2, 5),
      (3, 5),
      (4, 5),
      (1, 3),
      (2, 4),
    ]) {
      canvas.drawLine(points[a], points[b], line);
    }
    for (final point in points) {
      canvas.drawCircle(
        point,
        size.width * .085,
        Paint()..color = const Color(0xFF54DFF0),
      );
      canvas.drawCircle(
        point,
        size.width * .048,
        Paint()..color = const Color(0xFF11162A),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavLabel extends StatelessWidget {
  const _NavLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(23, 8, 16, 10),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF76849E),
        fontSize: 9,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected ? const Color(0xFF1C2042) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 42,
            child: Row(
              children: [
                const SizedBox(width: 13),
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? const Color(0xFFA99AFF)
                      : const Color(0xFF8795AE),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFADB9CD),
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: const Color(0xFF10172A),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFF25314C)),
    ),
    child: child,
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.text, this.trailing});
  final IconData icon;
  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: const Color(0xFF8992FF)),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 1.1,
        ),
      ),
      if (trailing != null) ...[
        const Spacer(),
        Text(
          trailing!,
          style: const TextStyle(color: Color(0xFF8795AE), fontSize: 10),
        ),
      ],
    ],
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: isError ? const Color(0xFF311A29) : const Color(0xFF142C2B),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(
        color: isError ? const Color(0xFF713448) : const Color(0xFF285A55),
      ),
    ),
    child: Row(
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.info_outline,
          size: 17,
          color: isError ? const Color(0xFFFF8495) : const Color(0xFF6DE2C1),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SelectableText(
            message,
            style: const TextStyle(fontSize: 12, color: Color(0xFFE6DDE4)),
          ),
        ),
      ],
    ),
  );
}

class _EvidenceBullet extends StatelessWidget {
  const _EvidenceBullet({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(Icons.circle, size: 6, color: color),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFB3BED0),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SmallEmpty extends StatelessWidget {
  const _SmallEmpty(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: Color(0xFF8F9DB5), fontSize: 11, height: 1.5),
  );
}

List<Map<String, dynamic>> _resultList(
  Map<String, dynamic>? result,
  String field,
) {
  final value = result?[field];
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Color _riskColor(String risk) => switch (risk.toLowerCase()) {
  'critical' => const Color(0xFFFF667D),
  'high' => const Color(0xFFFF9C68),
  'medium' => const Color(0xFFFFC668),
  'low' => const Color(0xFF4DD5B1),
  _ => const Color(0xFF9D8AFF),
};

IconData _changeIcon(String? status) => switch (status) {
  'added' => Icons.add_circle_outline,
  'removed' => Icons.remove_circle_outline,
  'renamed' => Icons.drive_file_rename_outline,
  _ => Icons.description_outlined,
};
