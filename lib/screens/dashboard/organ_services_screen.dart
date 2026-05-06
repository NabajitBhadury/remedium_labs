import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/organ.dart';
import '../../models/service.dart';
import '../../theme/app_theme.dart';
import '../../providers/lab_test_provider.dart';
import 'service_details_screen.dart';

class OrganServicesScreen extends StatefulWidget {
  final Organ organ;

  const OrganServicesScreen({super.key, required this.organ});

  @override
  State<OrganServicesScreen> createState() => _OrganServicesScreenState();
}

class _OrganServicesScreenState extends State<OrganServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LabTestProvider>();
      if (provider.tests.isEmpty && !provider.isLoading) {
        provider.fetchTests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<LabTestProvider>();
    var tests = provider.tests.where((t) => t.status.toLowerCase() == 'active').toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: widget.organ.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.organ.name,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                color: widget.organ.color,
                child: Center(
                  child: Icon(
                    widget.organ.icon,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tests for ${widget.organ.name}",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.isLoading && tests.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (tests.isEmpty)
                    const Center(child: Text("No tests found."))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tests.length,
                      itemBuilder: (context, index) {
                        final test = tests[index];
                        final service = Service(
                          id: test.id.toString(),
                          name: test.name,
                          price: test.mrp,
                          durationMinutes: 30,
                          description: 'Test Type: ${test.type} | TAT: ${test.tat}',
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ServiceDetailsScreen(service: service),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.science_outlined,
                                        color: AppTheme.accentColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            service.name,
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "₹${service.price.toStringAsFixed(0)} • ${service.durationMinutes} mins",
                                            style: GoogleFonts.inter(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (service
                                              .description
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              service.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: (50 * index).ms).slideX();
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
