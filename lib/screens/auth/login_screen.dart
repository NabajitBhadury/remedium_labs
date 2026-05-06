import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../providers/loader_provider.dart';
import 'register_screen.dart';
import '../../widgets/scaffold_with_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      context.read<LoaderProvider>().showLoader();

      final error = await context.read<AuthProvider>().login(
        _identifierController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) context.read<LoaderProvider>().hideLoader();

      if (error == null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ScaffoldWithNav()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 120,
                  height: 120,
                ).animate().fade().scale(),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fade().slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Sign in to access your dashboard',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fade().slideY(begin: 0.3, end: 0, delay: 100.ms),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email or Phone Number',
                    hintText: 'Enter email or 10-digit phone',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter email or phone number';
                    }
                    return null;
                  },
                ).animate().fade().slideX(begin: -0.2, end: 0, delay: 200.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : 'Enter password',
                ).animate().fade().slideX(begin: -0.2, end: 0, delay: 300.ms),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ).animate().fade().slideY(begin: 0.5, end: 0, delay: 400.ms),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Create New Account',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ).animate().fade(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
