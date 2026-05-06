import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/organ.dart';
import '../../models/franchise.dart';
import '../../models/service.dart';
import '../../theme/app_theme.dart';
import '../../providers/franchise_provider.dart';
import '../booking/booking_flow_screens.dart';

class OrganLabsScreen extends StatefulWidget {
  final Organ organ;

  const OrganLabsScreen({super.key, required this.organ});

  @override
  State<OrganLabsScreen> createState() => _OrganLabsScreenState();
}

class _OrganLabsScreenState extends State<OrganLabsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FranchiseProvider>();
      if (provider.franchises.isEmpty && !provider.isLoading) {
        provider.fetchFranchises();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FranchiseProvider>();
    final franchises = provider.franchises
        .where((f) => f.status.toLowerCase() == 'active')
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.organ.icon, color: widget.organ.color, size: 20),
            const SizedBox(width: 8),
            Text(
              '${widget.organ.name} Tests',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: provider.isLoading && franchises.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : franchises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off,
                          size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No labs found',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => provider.fetchFranchises(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ).animate().fadeIn(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: franchises.length,
                  itemBuilder: (context, index) {
                    final franchise = franchises[index];
                    return _buildFranchiseCard(context, franchise, index);
                  },
                ),
    );
  }

  Widget _buildFranchiseCard(
      BuildContext context, Franchise franchise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            // Generate organ-specific test and navigate to booking
            final generatedService = Service(
              id: 'organ_${widget.organ.name.toLowerCase()}',
              name: '${widget.organ.name} Comprehensive Profile',
              price: 1500,
              durationMinutes: 45,
              description:
                  'Complete analysis of ${widget.organ.name} function and health parameters.',
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingFlowScreen(
                  franchiseName: franchise.name,
                  franchiseId: franchise.franchiseId,
                  service: generatedService,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon avatar (instead of network image that needed mock URLs)
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        franchise.name,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              franchise.displayAddress,
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (franchise.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            franchise.category,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX();
  }
}
