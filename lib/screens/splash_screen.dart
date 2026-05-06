import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/scaffold_with_nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Restore session silently while splash plays — no redirect to login
    await Future.wait([
      context.read<AuthProvider>().tryRestoreSession(),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    if (!mounted) return;

    // Always go to the main app — guests browse freely, logged-in users are restored
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ScaffoldWithNav()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/logo.png', width: 80, height: 80),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .then()
                .shimmer(duration: 1200.ms),
            const SizedBox(height: 24),
            Text(
              'Remedium Labs',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'Your Health, Our Priority',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ).animate().fade(delay: 500.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
