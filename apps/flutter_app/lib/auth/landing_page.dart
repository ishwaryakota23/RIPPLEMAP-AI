import 'package:flutter/material.dart';

class RippleMapLandingPage extends StatefulWidget {
  const RippleMapLandingPage({
    super.key,
    required this.onLogin,
    required this.onSignUp,
  });

  final VoidCallback onLogin;
  final VoidCallback onSignUp;

  @override
  State<RippleMapLandingPage> createState() => _RippleMapLandingPageState();
}

class _RippleMapLandingPageState extends State<RippleMapLandingPage> {
  final _featuresKey = GlobalKey();
  final _workflowKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final section = key.currentContext;
    if (section == null) return;
    Scrollable.ensureVisible(
      section,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1023), Color(0xFF070B18), Color(0xFF080D1B)],
          ),
        ),
        child: SafeArea(
          child: SelectionArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _LandingHeader(
                    onLogin: widget.onLogin,
                    onSignUp: widget.onSignUp,
                    onFeatures: () => _scrollTo(_featuresKey),
                    onWorkflow: () => _scrollTo(_workflowKey),
                  ),
                  _HeroSection(
                    onLogin: widget.onLogin,
                    onSignUp: widget.onSignUp,
                  ),
                  _FeatureSection(sectionKey: _featuresKey),
                  _WorkflowSection(sectionKey: _workflowKey),
                  _LandingCta(onSignUp: widget.onSignUp),
                  _LandingFooter(
                    onFeatures: () => _scrollTo(_featuresKey),
                    onWorkflow: () => _scrollTo(_workflowKey),
                    onLogin: widget.onLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LandingHeader extends StatelessWidget {
  const _LandingHeader({
    required this.onLogin,
    required this.onSignUp,
    required this.onFeatures,
    required this.onWorkflow,
  });

  final VoidCallback onLogin;
  final VoidCallback onSignUp;
  final VoidCallback onFeatures;
  final VoidCallback onWorkflow;

  @override
  Widget build(BuildContext context) {
    return _ContentWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 1000;
            return Row(
              children: [
                const _BrandLockup(),
                if (!compact) ...[
                  const Spacer(),
                  _HeaderLink(label: 'Features', onTap: onFeatures),
                  _HeaderLink(label: 'How it works', onTap: onWorkflow),
                  const SizedBox(width: 20),
                ] else
                  const Spacer(),
                if (constraints.maxWidth >= 480)
                  TextButton(onPressed: onLogin, child: const Text('Login')),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onSignUp,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 19,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Get started'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFFB7C2D6), fontSize: 13),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onLogin, required this.onSignUp});

  final VoidCallback onLogin;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return _ContentWidth(
      child: Padding(
        padding: const EdgeInsets.only(top: 70, bottom: 82),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 860;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Eyebrow(
                  icon: Icons.bolt_outlined,
                  label: 'CODE CHANGE IMPACT INTELLIGENCE',
                ),
                const SizedBox(height: 25),
                Text(
                  'See the impact\nbefore the breakage.',
                  style: TextStyle(
                    fontSize: compact ? 40 : 62,
                    height: 1.08,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2.6,
                  ),
                ),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 565),
                  child: const Text(
                    'Understand how a pull request ripples through your codebase. RippleMap connects real GitHub changes to source-backed dependencies, affected modules, and the tests worth running next.',
                    style: TextStyle(
                      color: Color(0xFFAAB7CC),
                      fontSize: 16,
                      height: 1.75,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: onSignUp,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Get started'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(160, 52),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onLogin,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(132, 52),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF34415E)),
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Deterministic analysis first. AI explanations are optional.',
                  style: TextStyle(color: Color(0xFF8796B0), fontSize: 12),
                ),
              ],
            );

            const illustration = _ImpactIllustration();
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [copy, const SizedBox(height: 52), illustration],
              );
            }
            return Row(
              children: [
                Expanded(flex: 11, child: copy),
                const SizedBox(width: 55),
                const Expanded(flex: 9, child: illustration),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ImpactIllustration extends StatelessWidget {
  const _ImpactIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 370),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0E162B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263453)),
        boxShadow: const [
          BoxShadow(color: Color(0x243B5AE4), blurRadius: 80, spreadRadius: 1),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _WindowDot(color: Color(0xFFFF7589)),
              SizedBox(width: 7),
              _WindowDot(color: Color(0xFFFFC46C)),
              SizedBox(width: 7),
              _WindowDot(color: Color(0xFF4FD6B2)),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'HOW IMPACT FLOWS',
                  style: TextStyle(
                    color: Color(0xFF98A7C1),
                    fontSize: 10,
                    letterSpacing: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.account_tree_outlined, color: Color(0xFF9889FF)),
            ],
          ),
          SizedBox(height: 27),
          _FlowNode(
            icon: Icons.edit_note_outlined,
            label: 'Changed code',
            detail: 'Real pull request diff',
            accent: Color(0xFF9D8AFF),
            emphasis: true,
          ),
          _FlowConnector(),
          Row(
            children: [
              Expanded(
                child: _FlowNode(
                  icon: Icons.hub_outlined,
                  label: 'Dependencies',
                  detail: 'Parser-backed links',
                  accent: Color(0xFF57C9DF),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _FlowNode(
                  icon: Icons.science_outlined,
                  label: 'Test signals',
                  detail: 'Evidence and heuristics',
                  accent: Color(0xFF75D6A4),
                ),
              ),
            ],
          ),
          SizedBox(height: 22),
          Divider(color: Color(0xFF253250), height: 1),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.verified_outlined, color: Color(0xFF62D8C0), size: 16),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Illustrative workflow — findings come from your selected pull request.',
                  style: TextStyle(
                    color: Color(0xFF9BA9C0),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({
    required this.icon,
    required this.label,
    required this.detail,
    required this.accent,
    this.emphasis = false,
  });

  final IconData icon;
  final String label;
  final String detail;
  final Color accent;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: emphasis ? const Color(0xFF171B38) : const Color(0xFF101A30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: emphasis ? const Color(0xFF6556B5) : const Color(0xFF273653),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFF9BAAC1),
                    fontSize: 10,
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

class _FlowConnector extends StatelessWidget {
  const _FlowConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          const SizedBox(width: 33),
          Container(width: 1, color: const Color(0xFF5867A4)),
          const SizedBox(width: 11),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9889FF)),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({required this.sectionKey});

  final GlobalKey sectionKey;

  static const _features = [
    _FeatureData(
      icon: Icons.code,
      color: Color(0xFF9885FF),
      title: 'Real GitHub context',
      description:
          'Connect your account, browse authorized repositories, and analyze actual pull request changes.',
    ),
    _FeatureData(
      icon: Icons.account_tree_outlined,
      color: Color(0xFF55C9DD),
      title: 'Dependency graph',
      description:
          'Trace supported JavaScript and TypeScript imports with clear, consistent relationship direction.',
    ),
    _FeatureData(
      icon: Icons.bolt_outlined,
      color: Color(0xFFFFB866),
      title: 'Impact analysis',
      description:
          'Separate parser-confirmed dependencies from bounded potential impact paths and heuristics.',
    ),
    _FeatureData(
      icon: Icons.auto_awesome_outlined,
      color: Color(0xFFAF88FF),
      title: 'Groq AI insights',
      description:
          'Get evidence-grounded explanations and uncertainty notes when the backend AI integration is configured.',
    ),
    _FeatureData(
      icon: Icons.science_outlined,
      color: Color(0xFF69D6A3),
      title: 'Test recommendations',
      description:
          'Surface related tests using real repository references and explicitly disclosed heuristics.',
    ),
    _FeatureData(
      icon: Icons.fact_check_outlined,
      color: Color(0xFF85A9FF),
      title: 'Evidence-backed findings',
      description:
          'See why a component appears in the report, what is known, and what still needs developer review.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      color: const Color(0xFF0A1020),
      child: _ContentWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 86),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeading(
                eyebrow: 'WHAT RIPPLEMAP DOES',
                title: 'Less guesswork in every review.',
                description:
                    'An impact report built from the change and repository evidence—not a made-up dependency map.',
              ),
              const SizedBox(height: 34),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 620
                      ? 1
                      : constraints.maxWidth < 960
                      ? 2
                      : 3;
                  return GridView.builder(
                    itemCount: _features.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      mainAxisExtent: 186,
                    ),
                    itemBuilder: (context, index) =>
                        _FeatureCard(feature: _features[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureData {
  const _FeatureData({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _FeatureData feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF10182A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF253250)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(feature.icon, size: 22, color: feature.color),
          const SizedBox(height: 15),
          Text(
            feature.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              feature.description,
              style: const TextStyle(
                color: Color(0xFF9CAAC1),
                fontSize: 12,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowSection extends StatelessWidget {
  const _WorkflowSection({required this.sectionKey});

  final GlobalKey sectionKey;

  static const _steps = [
    _StepData(
      number: '01',
      title: 'Connect your GitHub',
      description:
          'Authorize access on the backend and browse repositories available to your account.',
      icon: Icons.link,
    ),
    _StepData(
      number: '02',
      title: 'Choose a pull request',
      description:
          'RippleMap retrieves the real change set and parses supported source files.',
      icon: Icons.difference_outlined,
    ),
    _StepData(
      number: '03',
      title: 'Review the ripple',
      description:
          'Inspect direct and potential impacts, related tests, uncertainty, and next steps.',
      icon: Icons.fact_check_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _ContentWidth(
      child: Padding(
        key: sectionKey,
        padding: const EdgeInsets.symmetric(vertical: 88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeading(
              eyebrow: 'HOW IT WORKS',
              title: 'From pull request to clear next steps.',
              description:
                  'A simple path from real changes to reviewable evidence.',
            ),
            const SizedBox(height: 36),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 760 ? 1 : 3;
                return GridView.count(
                  crossAxisCount: columns,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: columns == 1 ? 3.4 : 1.05,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _steps
                      .map((step) => _WorkflowStep(step: step))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StepData {
  const _StepData({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String number;
  final String title;
  final String description;
  final IconData icon;
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({required this.step});

  final _StepData step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF24324F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                step.number,
                style: const TextStyle(
                  color: Color(0xFF9A8BFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Icon(step.icon, color: const Color(0xFF8B9CFF), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            step.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: const TextStyle(
              color: Color(0xFF9CAAC1),
              fontSize: 12,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingCta extends StatelessWidget {
  const _LandingCta({required this.onSignUp});

  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return _ContentWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 78),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 38),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF25204D), Color(0xFF132A48)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF4B4D85)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 690;
              const copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Make the next review more confident.',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 9),
                  Text(
                    'Connect a repository and start with a real pull request.',
                    style: TextStyle(
                      color: Color(0xFFC2C7DB),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              );
              final action = FilledButton.icon(
                onPressed: onSignUp,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Get started'),
                style: FilledButton.styleFrom(minimumSize: const Size(158, 50)),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, const SizedBox(height: 22), action],
                );
              }
              return Row(
                children: [
                  const Expanded(child: copy),
                  const SizedBox(width: 20),
                  action,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LandingFooter extends StatelessWidget {
  const _LandingFooter({
    required this.onFeatures,
    required this.onWorkflow,
    required this.onLogin,
  });

  final VoidCallback onFeatures;
  final VoidCallback onWorkflow;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF202B45))),
      ),
      child: _ContentWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 27),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 900;
              final nav = Wrap(
                spacing: 4,
                runSpacing: 2,
                children: [
                  _FooterLink(label: 'Features', onTap: onFeatures),
                  _FooterLink(label: 'How it works', onTap: onWorkflow),
                  _FooterLink(label: 'Login', onTap: onLogin),
                ],
              );
              const brand = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BrandLockup(compact: true),
                  SizedBox(height: 8),
                  Text(
                    'See the impact before the breakage.',
                    style: TextStyle(color: Color(0xFF9CAAC1), fontSize: 11),
                  ),
                ],
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [brand, const SizedBox(height: 16), nav],
                );
              }
              return Row(children: [brand, const Spacer(), nav]);
            },
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF9DAAC1), fontSize: 11),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(icon: Icons.circle, label: eyebrow, iconSize: 7),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Text(
            description,
            style: const TextStyle(
              color: Color(0xFF9DAAC1),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.icon, required this.label, this.iconSize = 16});

  final IconData icon;
  final String label;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: const Color(0xFF9C8AFF)),
        const SizedBox(width: 9),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB7A9FF),
            fontSize: 10,
            letterSpacing: 1.25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 30 : 38,
          height: compact ? 30 : 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF816CFF), Color(0xFF398DFF)],
            ),
            borderRadius: BorderRadius.circular(compact ? 9 : 12),
          ),
          child: Icon(
            Icons.hub_rounded,
            color: Colors.white,
            size: compact ? 17 : 21,
          ),
        ),
        SizedBox(width: compact ? 8 : 10),
        Text(
          'RippleMap ',
          style: TextStyle(
            fontSize: compact ? 15 : 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'AI',
          style: TextStyle(
            color: const Color(0xFF9A8AFF),
            fontSize: compact ? 15 : 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ContentWidth extends StatelessWidget {
  const _ContentWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: child,
        ),
      ),
    );
  }
}
