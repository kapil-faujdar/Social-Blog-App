import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as local_auth;
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _sentOnce = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
  }

  void _startCooldown() {
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    if (_sentOnce) return;
    _sentOnce = true;
    final user = Provider.of<local_auth.AuthProvider>(context, listen: false).user;
    try {
      await user?.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent")),
      );
      _startCooldown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _resendVerificationEmail() async {
    final user = Provider.of<local_auth.AuthProvider>(context, listen: false).user;
    try {
      await user?.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent")),
      );
      _startCooldown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _checkVerification() async {
    final authProvider = Provider.of<local_auth.AuthProvider>(context, listen: false);
    final user = authProvider.user;
    await user?.reload();
    if (!mounted) return;
    await authProvider.reloadUser();
    if (user?.emailVerified == true) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Still not verified")),
      );
    }
  }

  void _useAnotherAccount() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    Future.microtask(() async {
      final user = Provider.of<local_auth.AuthProvider>(context, listen: false).user;
      try {
        await user?.delete();
      } catch (_) {
        await Provider.of<local_auth.AuthProvider>(context, listen: false).logout();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                "A verification email has been sent to your email address.",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _secondsRemaining > 0 ? null : _resendVerificationEmail,
                icon: const Icon(Icons.send),
                label: Text(
                  _secondsRemaining > 0
                      ? 'Resend in $_secondsRemaining sec'
                      : 'Resend Verification Email',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _checkVerification,
                icon: const Icon(Icons.verified),
                label: const Text("I Verified My Email"),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: _useAnotherAccount,
                child: const Text("Use another account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
