import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/lab_test_provider.dart';
import '../../models/lab_test.dart';

class RateChartScreen extends StatefulWidget {
  const RateChartScreen({super.key});

  @override
  State<RateChartScreen> createState() => _RateChartScreenState();
}

class _RateChartScreenState extends State<RateChartScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LabTest> _filteredTests(List<LabTest> all) {
    List<LabTest> result = _selectedCategory == 'All'
        ? all
        : all.where((t) => t.type == _selectedCategory).toList();
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (t) =>
                t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.type.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LabTestProvider>();
    final categories = provider.categories;
    final activeTests = provider.tests.where((t) => t.status.toLowerCase() == 'active').toList();
    final filtered = _filteredTests(activeTests);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Health Rate Chart',
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.fetchTests(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (provider.isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: AppTheme.primaryColor,
            ),
          if (!provider.isLoading && categories.isNotEmpty)
            _buildCategoryList(categories),
          Expanded(
            child: _buildBody(provider, filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LabTestProvider provider, List<LabTest> filtered) {
    if (provider.isLoading && provider.tests.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (provider.error != null && provider.tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to load tests',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.fetchTests(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No tests found',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final test = filtered[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  test.sampleType,
                  style: GoogleFonts.inter(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          test.type,
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          'TAT: ${test.tat}',
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${test.mrp.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (40 * index).ms).slideX(begin: 0.05);
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search by test name or type...',
            hintStyle:
                GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<String> categories) {
    return Container(
      color: Colors.white,
      height: 60,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
