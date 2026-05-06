import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/loader_provider.dart';
import 'providers/lab_test_provider.dart';
import 'providers/franchise_provider.dart';
import 'screens/splash_screen.dart';
import 'widgets/loading_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LoaderProvider()),
        ChangeNotifierProvider(create: (_) => LabTestProvider()),
        ChangeNotifierProvider(create: (_) => FranchiseProvider()),
      ],
      child: MaterialApp(
        title: 'Remedium Labs',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return GlobalLoadingOverlay(child: child!);
        },
        home: const SplashScreen(),
      ),
    );
  }
}
