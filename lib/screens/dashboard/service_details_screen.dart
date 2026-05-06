import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/service.dart';
import '../../theme/app_theme.dart';
import '../labs/labs_for_service_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final Service service;

  const ServiceDetailsScreen({super.key, required this.service});

  void _showServiceOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose Service Type",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(
                  "Home Collection",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "Sample collected at your doorstep (+₹10)",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LabsForServiceScreen(
                        service: service,
                        isHomeCollection: true,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: AppTheme.accentColor,
                  ),
                ),
                title: Text(
                  "Visit Lab",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "Visit our partner lab at your scheduled time",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LabsForServiceScreen(service: service),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Test Details",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.science_outlined,
                              size: 40,
                              color: AppTheme.accentColor,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Duration: ${service.durationMinutes} mins",
                                      style: GoogleFonts.inter(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: 24),
                    Text(
                      "About Test",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 12),
                    Text(
                      service.description.isEmpty
                          ? "This test evaluates key parameters and helps in early diagnosis and monitoring of various conditions. Please book to get accurate lab results."
                          : service.description,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 24),
                    _buildRequirementCard(
                      icon: Icons.fastfood_outlined,
                      title: "Fasting",
                      value: "8-12 Hours Recommended",
                      delay: 200,
                    ),
                    const SizedBox(height: 12),
                    _buildRequirementCard(
                      icon: Icons.bloodtype_outlined,
                      title: "Sample Type",
                      value: "Blood Sample",
                      delay: 250,
                    ),
                    const SizedBox(height: 12),
                    _buildRequirementCard(
                      icon: Icons.description_outlined,
                      title: "Report Time",
                      value: "Within 24-48 Hours",
                      delay: 300,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Total Price",
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "₹${service.price.toStringAsFixed(0)}",
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showServiceOptionsBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Book Test",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementCard({
    required IconData icon,
    required String title,
    required String value,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey.shade700, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1);
  }
}
