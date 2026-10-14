import 'package:flutter/material.dart';
import 'package:ripplemap_client/ripplemap_client.dart';

import 'ripplemap_auth_service.dart';

enum AuthPageMode { login, signUp, resetPassword }

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.mode,
    required this.authService,
    required this.onBack,
    required this.onAuthenticated,
    required this.onModeChanged,
  });

  final AuthPageMode mode;
  final RippleMapAuthService authService;
  final VoidCallback onBack;
  final Future<void> Function() onAuthenticated;
  final ValueChanged<AuthPageMode> onModeChanged;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _verificationCode = TextEditingController();
  UuidValue? _requestId;
  String? _resetToken;
  String? _message;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _verificationCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      switch (widget.mode) {
        case AuthPageMode.login:
          await widget.authService.login(_email.text.trim(), _password.text);
          await widget.onAuthenticated();
        case AuthPageMode.signUp:
          await _submitSignUp();
        case AuthPageMode.resetPassword:
          await _submitPasswordReset();
      }
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitSignUp() async {
    final requestId = _requestId;
    if (requestId == null) {
      final newRequestId = await widget.authService.startRegistration(
        _email.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _requestId = newRequestId;
        _message =
            'A verification code was sent. In local development, check the Serverpod terminal for the code.';
      });
      return;
    }

    final registrationToken = await widget.authService.verifyRegistrationCode(
      requestId,
      _verificationCode.text.trim(),
    );
    await widget.authService.finishRegistration(
      registrationToken,
      _password.text,
    );
    await widget.onAuthenticated();
  }

  Future<void> _submitPasswordReset() async {
    final requestId = _requestId;
    if (requestId == null) {
      final newRequestId = await widget.authService.startPasswordReset(
        _email.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _requestId = newRequestId;
        _message =
            'If an account exists for this email, a reset code has been sent. In local development, check the Serverpod terminal.';
      });
      return;
    }

    final resetToken = _resetToken;
    if (resetToken == null) {
      final verifiedToken = await widget.authService.verifyPasswordResetCode(
        requestId,
        _verificationCode.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _resetToken = verifiedToken;
        _message = 'Code verified. Choose a new password.';
      });
      return;
    }

    await widget.authService.finishPasswordReset(resetToken, _password.text);
    if (!mounted) return;
    widget.onModeChanged(AuthPageMode.login);
    setState(() {
      _requestId = null;
      _resetToken = null;
      _verificationCode.clear();
      _password.clear();
      _message = 'Your password has been changed. You can now sign in.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 850;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (!compact)
              Expanded(
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.all(64),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF141B35), Color(0xFF090E1D)],
                    ),
                  ),
                  child: const _AuthBrandPanel(),
                ),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(compact ? 22 : 56),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Back to RippleMap'),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _subtitle,
                          style: const TextStyle(
                            color: Color(0xFFA5B1C8),
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Form(
                          key: _formKey,
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_showEmail)
                                  _field(
                                    controller: _email,
                                    label: 'Email address',
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    validator: _validateEmail,
                                  ),
                                if (_showVerificationCode) ...[
                                  const SizedBox(height: 16),
                                  _field(
                                    controller: _verificationCode,
                                    label: 'Verification code',
                                    autofillHints: const [
                                      AutofillHints.oneTimeCode,
                                    ],
                                  ),
                                ],
                                if (_showPassword) ...[
                                  const SizedBox(height: 16),
                                  _field(
                                    controller: _password,
                                    label:
                                        widget.mode ==
                                            AuthPageMode.resetPassword
                                        ? 'New password'
                                        : 'Password',
                                    obscureText: true,
                                    autofillHints: [
                                      if (widget.mode == AuthPageMode.login)
                                        AutofillHints.password
                                      else
                                        AutofillHints.newPassword,
                                    ],
                                    validator: _validatePassword,
                                  ),
                                ],
                                if (_error != null) ...[
                                  const SizedBox(height: 18),
                                  _FeedbackBanner(text: _error!, error: true),
                                ],
                                if (_message != null) ...[
                                  const SizedBox(height: 18),
                                  _FeedbackBanner(text: _message!),
                                ],
                                const SizedBox(height: 22),
                                FilledButton(
                                  onPressed: _busy ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                  ),
                                  child: _busy
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(_buttonLabel),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (widget.mode == AuthPageMode.login)
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            runSpacing: 8,
                            children: [
                              TextButton(
                                onPressed: () => widget.onModeChanged(
                                  AuthPageMode.resetPassword,
                                ),
                                child: const Text('Forgot password?'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    widget.onModeChanged(AuthPageMode.signUp),
                                child: const Text('Create account'),
                              ),
                            ],
                          )
                        else if (widget.mode == AuthPageMode.signUp)
                          TextButton(
                            onPressed: () =>
                                widget.onModeChanged(AuthPageMode.login),
                            child: const Text(
                              'Already have an account? Sign in',
                            ),
                          )
                        else
                          TextButton(
                            onPressed: () =>
                                widget.onModeChanged(AuthPageMode.login),
                            child: const Text('Back to sign in'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _title => switch (widget.mode) {
    AuthPageMode.login => 'Welcome back',
    AuthPageMode.signUp =>
      _requestId == null ? 'Create your account' : 'Verify your email',
    AuthPageMode.resetPassword =>
      _requestId == null
          ? 'Reset your password'
          : _resetToken == null
          ? 'Enter your reset code'
          : 'Choose a new password',
  };

  String get _subtitle => switch (widget.mode) {
    AuthPageMode.login => 'Sign in to continue to your impact workspace.',
    AuthPageMode.signUp =>
      _requestId == null
          ? 'Get evidence-backed insight into the changes you ship.'
          : 'Enter the code sent to ${_email.text.trim()} to verify your email.',
    AuthPageMode.resetPassword =>
      'We will help you securely regain access to your account.',
  };

  bool get _showEmail =>
      _requestId == null || widget.mode == AuthPageMode.login;

  bool get _showVerificationCode =>
      _requestId != null &&
      (widget.mode == AuthPageMode.signUp ||
          (widget.mode == AuthPageMode.resetPassword && _resetToken == null));

  bool get _showPassword =>
      widget.mode == AuthPageMode.login ||
      (widget.mode == AuthPageMode.signUp && _requestId != null) ||
      (widget.mode == AuthPageMode.resetPassword && _resetToken != null);

  String get _buttonLabel {
    if (_busy) return 'Please wait...';
    return switch (widget.mode) {
      AuthPageMode.login => 'Sign in',
      AuthPageMode.signUp =>
        _requestId == null
            ? 'Send verification code'
            : 'Verify and create account',
      AuthPageMode.resetPassword =>
        _requestId == null
            ? 'Send reset code'
            : _resetToken == null
            ? 'Verify code'
            : 'Change password',
    };
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Use at least 8 characters.';
    }
    if (value.trim() != value) {
      return 'Password cannot start or end with spaces.';
    }
    return null;
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<String>? autofillHints,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      obscureText: obscureText,
      enableSuggestions: !obscureText,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF10172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF293653)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF293653)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8C7BFF), width: 1.5),
        ),
      ),
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _BrandLockup(),
        SizedBox(height: 58),
        Text(
          'Understand the ripple of every code change.',
          style: TextStyle(
            fontSize: 44,
            height: 1.12,
            letterSpacing: -1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Repository evidence first. Clear impact paths and next steps when you need them.',
          style: TextStyle(color: Color(0xFFAFBBD0), fontSize: 16, height: 1.6),
        ),
        SizedBox(height: 38),
        _TrustLine(
          icon: Icons.shield_outlined,
          text: 'Your repositories stay scoped to your account',
        ),
        SizedBox(height: 16),
        _TrustLine(
          icon: Icons.account_tree_outlined,
          text: 'Dependency edges come from deterministic analysis',
        ),
      ],
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.text, this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final color = error ? const Color(0xFFFF7488) : const Color(0xFF59D3C2);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            error ? Icons.error_outline : Icons.check_circle_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, height: 1.45, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustLine extends StatelessWidget {
  const _TrustLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9B8AFF), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFFCFD6E4), fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF816CFF), Color(0xFF398DFF)],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 23),
        ),
        const SizedBox(width: 12),
        const Text(
          'RippleMap ',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const Text(
          'AI',
          style: TextStyle(
            color: Color(0xFF8E82FF),
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
