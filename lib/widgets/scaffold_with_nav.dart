import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/auth/login_screen.dart';
import '../theme/app_theme.dart';

class ScaffoldWithNav extends StatefulWidget {
  const ScaffoldWithNav({super.key});

  @override
  State<ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends State<ScaffoldWithNav> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AppointmentsScreen(),
    const PaymentsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index, bool isAuthenticated) {
    if (index == 3 && !isAuthenticated) {
      // Intercept and show login explicitly instead of switching tabs
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              _onItemTapped(index, isAuthenticated),
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primaryColor.withOpacity(0.1),
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppTheme.primaryColor),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(
                Icons.calendar_month,
                color: AppTheme.primaryColor,
              ),
              label: 'My Appointment',
            ),
            const NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(
                Icons.account_balance_wallet,
                color: AppTheme.primaryColor,
              ),
              label: 'My Payment',
            ),
            if (isAuthenticated)
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppTheme.primaryColor),
                label: 'Profile',
              )
            else
              const NavigationDestination(
                icon: Icon(Icons.login_outlined),
                selectedIcon: Icon(Icons.login, color: AppTheme.primaryColor),
                label: 'Show Login',
              ),
          ],
        ),
      ),
    );
  }
}
