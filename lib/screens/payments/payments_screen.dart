import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text("My Payments"),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  FontAwesomeIcons.wallet,
                  size: 64,
                  color: AppTheme.primaryColor.withOpacity(0.8),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                "No Data",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              Text(
                "Please login to view.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text("Login Now"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      );
    }

    // Mock Data
    final transactions = [
      {
        "title": "Thyroid Profile",
        "date": "Oct 24, 2023",
        "amount": 50.0,
        "status": "Success",
        "lab": "City Lab",
      },
      {
        "title": "Lipid Profile",
        "date": "Sep 12, 2023",
        "amount": 60.0,
        "status": "Success",
        "lab": "Health Plus",
      },
      {
        "title": "Full Body Checkup",
        "date": "Aug 05, 2023",
        "amount": 120.0,
        "status": "Failed",
        "lab": "MediCare",
      },
      {
        "title": "Vitamin D Test",
        "date": "Jul 15, 2023",
        "amount": 45.0,
        "status": "Success",
        "lab": "City Lab",
      },
      {
        "title": "Blood Sugar Fasting",
        "date": "Jun 20, 2023",
        "amount": 15.0,
        "status": "Success",
        "lab": "Health Plus",
      },
    ];

    double totalSpent = transactions
        .where((t) => t['status'] == 'Success')
        .fold(0.0, (sum, item) => sum + (item['amount'] as double));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withBlue(200),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Total Spent",
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn().slideX(),
                        const SizedBox(height: 8),
                        Text(
                          "₹${totalSpent.toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildStatBadge(
                              icon: Icons.check_circle,
                              label: "4 Paid",
                              color: Colors.white.withOpacity(0.2),
                              textColor: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            _buildStatBadge(
                              icon: Icons.pending,
                              label: "1 Failed",
                              color: Colors.white.withOpacity(0.2),
                              textColor: Colors.white,
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms).slideX(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              "My Payments",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                "Recent Transactions",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final txn = transactions[index];
              return _buildPaymentCard(context, txn, index);
            }, childCount: transactions.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    Map<String, dynamic> txn,
    int index,
  ) {
    final isSuccess = txn['status'] == "Success";
    final amount = txn['amount'] as double;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Show details
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.errorColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess
                          ? FontAwesomeIcons.check
                          : FontAwesomeIcons.xmark,
                      color: isSuccess
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          txn['title'] as String,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${txn['lab']} • ${txn['date']}",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "-₹${amount.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSuccess
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (txn['status'] as String).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSuccess
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0),
    );
  }
}
