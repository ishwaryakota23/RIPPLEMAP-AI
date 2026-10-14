import 'package:flutter/material.dart';

import 'auth_pages.dart';
import 'landing_page.dart';
import 'ripplemap_auth_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.dashboardBuilder,
  });

  final RippleMapAuthService authService;
  final Widget Function(Future<void> Function() onLogout) dashboardBuilder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AuthPageMode? _mode;
  String? _userId;
  String? _error;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final userId = await widget.authService.currentUserId();
      if (!mounted) return;
      setState(() {
        _userId = userId;
        _checking = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _checking = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await widget.authService.logout();
      await _checkAuthentication();
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_error != null) {
      return _AuthenticationUnavailable(
        error: _error!,
        onRetry: _checkAuthentication,
      );
    }
    final userId = _userId;
    if (userId != null) {
      return widget.dashboardBuilder(_logout);
    }
    final mode = _mode;
    if (mode != null) {
      return AuthPage(
        mode: mode,
        authService: widget.authService,
        onBack: () => setState(() => _mode = null),
        onAuthenticated: _checkAuthentication,
        onModeChanged: (nextMode) => setState(() => _mode = nextMode),
      );
    }
    return RippleMapLandingPage(
      onLogin: () => setState(() => _mode = AuthPageMode.login),
      onSignUp: () => setState(() => _mode = AuthPageMode.signUp),
    );
  }
}

class _AuthenticationUnavailable extends StatelessWidget {
  const _AuthenticationUnavailable({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 42,
                  color: Color(0xFF9B8AFF),
                ),
                const SizedBox(height: 18),
                const Text(
                  'We could not verify your session',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF9CAAC1),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
