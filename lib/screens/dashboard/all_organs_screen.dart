import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../models/organ.dart';
import '../../theme/app_theme.dart';
import '../../services/mock_data_service.dart';
import 'organ_services_screen.dart';

class AllOrgansScreen extends StatefulWidget {
  const AllOrgansScreen({super.key});

  @override
  State<AllOrgansScreen> createState() => _AllOrgansScreenState();
}

class _AllOrgansScreenState extends State<AllOrgansScreen> {
  final MockDataService _dataService = MockDataService();
  List<Organ> _organs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final organs = await _dataService.getOrgans();
    if (mounted) {
      setState(() {
        _organs = organs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "All Organs",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _organs.length,
              itemBuilder: (context, index) {
                final organ = _organs[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrganServicesScreen(organ: organ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: organ.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              organ.icon,
                              color: organ.color,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          organ.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1),
                );
              },
            ),
    );
  }
}
