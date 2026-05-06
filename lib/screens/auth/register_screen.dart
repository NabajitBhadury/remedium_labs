import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loader_provider.dart';
import '../../widgets/scaffold_with_nav.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedGender = 'Male';

  void _register() async {
    if (_formKey.currentState!.validate()) {
      context.read<LoaderProvider>().showLoader();

      final error = await context.read<AuthProvider>().register(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _emailController.text.trim(),
        int.tryParse(_ageController.text.trim()) ?? 0,
        _passwordController.text.trim(),
        gender: _selectedGender,
      );

      if (mounted) context.read<LoaderProvider>().hideLoader();

      if (error == null && mounted) {
        // Go to dashboard, remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ScaffoldWithNav()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Registration failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
                  width: 100,
                  height: 100,
                ).animate().fade().scale(),
                const SizedBox(height: 16),
                Text(
                  'Join Us',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fade().slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Start your health journey today',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fade().slideY(begin: 0.3, end: 0, delay: 100.ms),
                const SizedBox(height: 32),
                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : 'Enter full name',
                ).animate().fade().slideX(begin: -0.2, end: 0, delay: 200.ms),
                const SizedBox(height: 16),
                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter phone number';
                    }
                    if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Enter valid phone number';
                    }
                    return null;
                  },
                ).animate().fade().slideX(begin: -0.2, end: 0, delay: 250.ms),
                const SizedBox(height: 16),
                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter email address';
                    }
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ).animate().fade().slideX(begin: -0.2, end: 0, delay: 300.ms),
                const SizedBox(height: 16),
                // Age
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age <= 0 || age > 150) {
                      return 'Enter a valid age';
                    }
                    return null;
                  },
                ).animate().fade().slideX(begin: -0.2, end: 0, delay: 320.ms),
                const SizedBox(height: 16),
                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map(
                        (label) =>
                            DropdownMenuItem(value: label, child: Text(label)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ).animate().fade().slideX(begin: -0.2, end: 0, delay: 350.ms),
                const SizedBox(height: 16),
                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) => value != null && value.length > 5
                      ? null
                      : 'Password must be at least 6 characters',
                ).animate().fade().slideX(begin: -0.2, end: 0, delay: 400.ms),
                const SizedBox(height: 16),
                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ).animate().fade().slideX(begin: -0.2, end: 0, delay: 450.ms),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ).animate().fade().slideY(begin: 0.5, end: 0, delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
