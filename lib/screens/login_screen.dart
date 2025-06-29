import 'verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // animation
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart' as local_auth;
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/color_picker_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<bool> _isUsernameTaken(String username) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.userService.isUsernameTaken(username);
  }

  String? _validateUsername(String username) {
    if (username.isEmpty) return 'Username cannot be empty';
    if (!RegExp(r'^[a-z]+$').hasMatch(username)) return 'Username must contain only lowercase letters (a-z)';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim().toLowerCase();
      final authProvider = Provider.of<local_auth.AuthProvider>(context, listen: false);

      if (_isLogin) {
        await authProvider.login(email: email, password: password);
      } else {
        final error = _validateUsername(username);
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
          return;
        }
        if (await _isUsernameTaken(username)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username already taken')),
          );
          return;
        }
        await authProvider.signUp(email: email, password: password, username: username);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = Provider.of<ThemeProvider>(context).accentColor ?? Colors.cyan;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor,
              theme.brightness == Brightness.dark
                  ? accentColor.withOpacity(0.5)
                  : accentColor.withOpacity(0.2),
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Theme and color toggle at the top right
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        IconData icon;
                        String tooltip;
                        switch (themeProvider.themeMode) {
                          case ThemeMode.light:
                            icon = Icons.wb_sunny_rounded;
                            tooltip = 'Light Mode';
                            break;
                          case ThemeMode.dark:
                            icon = Icons.nightlight_round;
                            tooltip = 'Dark Mode';
                            break;
                          default:
                            icon = Icons.brightness_auto_rounded;
                            tooltip = 'System Mode';
                        }
                        return IconButton(
                          icon: Icon(icon, color: accentColor, size: 28),
                          tooltip: 'Toggle Theme ($tooltip)',
                          onPressed: () => themeProvider.toggleTheme(),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.palette_rounded, color: accentColor, size: 28),
                      tooltip: 'Customize Colors',
                      onPressed: () async {
                        final newColor = await showModalBottomSheet<Color?>(
                          context: context,
                          builder: (context) => ColorPickerSheet(),
                        );
                        if (newColor != null) {
                          Provider.of<ThemeProvider>(context, listen: false).setAccentColor(newColor);
                        }
                      },
                    ),
                  ],
                ),
                // Lottie animation at the top, full width
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Lottie.asset(
                    _isLogin
                        ? 'assets/animations/welcome_guy.json'
                        : 'assets/animations/signup.json',
                    controller: _animController,
                    onLoaded: (composition) {
                      _animController
                        ..duration = composition.duration
                        ..repeat();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Large, bold heading
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                  child: Text(
                    _isLogin ? 'Welcome to Social Blog App!' : "Let's get started!",
                    key: ValueKey(_isLogin),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Login to continue and connect with the world.'
                      : 'Create your account to join the community!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Form fields
                Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                        filled: true,
                        fillColor: theme.brightness == Brightness.light ? const Color(0xFFF5F5F7) : theme.inputDecorationTheme.fillColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        filled: true,
                        fillColor: theme.brightness == Brightness.light ? const Color(0xFFF5F5F7) : theme.inputDecorationTheme.fillColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          filled: true,
                          fillColor: theme.brightness == Brightness.light ? const Color(0xFFF5F5F7) : theme.inputDecorationTheme.fillColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-z]')),
                        ],
                      ),
                    ],
                    const SizedBox(height: 28),
                    AnimatedScale(
                      scale: _isLoading ? 0.97 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submit,
                          icon: Icon(
                            _isLogin ? Icons.login_rounded : Icons.person_add_alt_1_rounded,
                            color: accentColor,
                          ),
                          label: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: accentColor.withOpacity(0.18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Toggle login/signup
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? 'Create account' : 'Back to Login',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
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
