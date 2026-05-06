import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../models/franchise.dart';
import '../../theme/app_theme.dart';
import '../../providers/franchise_provider.dart';
import '../booking/booking_flow_screens.dart';

class LabsForServiceScreen extends StatefulWidget {
  final Service service;
  final bool isHomeCollection;

  const LabsForServiceScreen({
    super.key,
    required this.service,
    this.isHomeCollection = false,
  });

  @override
  State<LabsForServiceScreen> createState() => _LabsForServiceScreenState();
}

class _LabsForServiceScreenState extends State<LabsForServiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCity;

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Franchise> _filtered(List<Franchise> all) {
    List<Franchise> result = all
        .where((f) => f.status.toLowerCase() == 'active')
        .toList();
    if (_selectedCity != null) {
      result = result.where((f) => f.city == _selectedCity).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((f) =>
              f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              f.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              f.address.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FranchiseProvider>();
    final franchises = _filtered(provider.franchises);
    final cities = provider.cities;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Select Lab',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.fetchFranchises(city: _selectedCity),
          ),
        ],
      ),
      body: Column(
        children: [
          // Test info banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.science_outlined,
                      color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.service.name} — ₹${widget.service.price.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (widget.isHomeCollection)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Home Collection',
                        style: GoogleFonts.inter(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search labs by name or city...',
                hintStyle:
                    GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.primaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // City filter chips
          if (cities.isNotEmpty)
            Container(
              color: Colors.white,
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _cityChip(null, 'All'),
                  ...cities.map((c) => _cityChip(c, c)),
                ],
              ),
            ),

          if (provider.isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: AppTheme.primaryColor,
            ),

          Expanded(child: _buildBody(provider, franchises)),
        ],
      ),
    );
  }

  Widget _cityChip(String? city, String label) {
    final isSelected = _selectedCity == city;
    return GestureDetector(
      onTap: () => setState(() => _selectedCity = city),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(FranchiseProvider provider, List<Franchise> franchises) {
    if (provider.isLoading && provider.franchises.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (provider.error != null && provider.franchises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Failed to load labs',
                style: GoogleFonts.outfit(
                    fontSize: 18, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(provider.error ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.fetchFranchises(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    if (franchises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No labs found',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: franchises.length,
      itemBuilder: (context, index) {
        final franchise = franchises[index];
        return _buildFranchiseCard(franchise, index);
      },
    );
  }

  Widget _buildFranchiseCard(Franchise franchise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingFlowScreen(
                  franchiseName: franchise.name,
                  franchiseId: franchise.franchiseId,
                  service: widget.service,
                  isHomeCollection: widget.isHomeCollection,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.local_hospital_outlined,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        franchise.name,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              franchise.displayAddress,
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (franchise.contactNumber.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 13, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              franchise.contactNumber,
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              franchise.category.isNotEmpty
                                  ? franchise.category
                                  : 'Diagnostic Center',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '₹${widget.service.price.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
  }
}
