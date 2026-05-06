import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/organ.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import 'organ_labs_screen.dart';

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
    _loadOrgans();
  }

  Future<void> _loadOrgans() async {
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
          "Find by Organ",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
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
                        builder: (_) => OrganLabsScreen(organ: organ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              organ.icon,
                              color: organ.color.withOpacity(0.8),
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        organ.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (50 * index).ms).scale();
              },
            ),
    );
  }
}
