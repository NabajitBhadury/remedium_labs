import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class CollectSampleScreen extends StatefulWidget {
  const CollectSampleScreen({super.key});

  @override
  State<CollectSampleScreen> createState() => _CollectSampleScreenState();
}

class _CollectSampleScreenState extends State<CollectSampleScreen> {
  final List<Map<String, dynamic>> _tests = [
    {
      'title': 'Routine Blood Test',
      'desc': 'Complete blood count and basic panels for routine checkup.',
      'icon': Icons.bloodtype,
      'price': '₹450',
      'selected': false,
      'time': '10-12 hrs fasting'
    },
    {
      'title': 'Advanced Body Profile',
      'desc': 'Comprehensive checkup for organs and vitamin deficiencies.',
      'icon': Icons.monitor_heart,
      'price': '₹2000',
      'selected': false,
      'time': '12 hrs fasting'
    },
    {
      'title': 'COVID-19 RT-PCR',
      'desc': 'Home swab collection for COVID-19 with 24hr reports.',
      'icon': Icons.coronavirus,
      'price': '₹800',
      'selected': false,
      'time': 'No fasting'
    },
    {
      'title': 'Urine Culture',
      'desc': 'Check for urinary tract infections and related issues.',
      'icon': Icons.science,
      'price': '₹350',
      'selected': false,
      'time': 'Morning sample'
    },
  ];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    bool hasSelection = _tests.any((t) => t['selected'] == true);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Collect My Sample',
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Home Sample Collection",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 8),
                  Text(
                    "Select tests for home sample collection by our trained phlebotomists.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideX(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final test = _tests[index];
                  final isSelected = test['selected'] == true;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        test['selected'] = !isSelected;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                          if (isSelected)
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppTheme.primaryColor 
                                      : AppTheme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  test['icon'] as IconData,
                                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      test['title'] as String,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      test['desc'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                child: isSelected 
                                  ? const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 28, key: ValueKey('checked'))
                                  : Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 28, key: const ValueKey('unchecked')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
                                    const SizedBox(width: 6),
                                    Text(
                                      test['time'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  test['price'] as String,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
                },
                childCount: _tests.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomSheet: hasSelection ? Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '₹${_calculateTotal()}',
                      style: GoogleFonts.outfit(
                        color: AppTheme.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showSchedulingSheet(context),
                  icon: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                  label: Text('Schedule Pickup', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().slideY(begin: 1.0, duration: 400.ms, curve: Curves.easeOutCubic) : const SizedBox.shrink(),
    );
  }

  int _calculateTotal() {
    int total = 0;
    for (var test in _tests) {
      if (test['selected'] == true) {
        String priceStr = (test['price'] as String).replaceAll('₹', '');
        total += int.tryParse(priceStr) ?? 0;
      }
    }
    return total;
  }

  void _showSchedulingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildScheduleSheet(),
    );
  }

  Widget _buildScheduleSheet() {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Schedule Your Pickup',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildDateTimePicker(
                icon: Icons.calendar_today,
                title: 'Select Date',
                value: _selectedDate != null ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" : 'Choose a date',
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setSheetState(() => _selectedDate = date);
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildDateTimePicker(
                icon: Icons.access_time,
                title: 'Select Time Slot',
                value: _selectedTime != null ? _selectedTime!.format(context) : 'Choose a time',
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (time != null) {
                    setSheetState(() => _selectedTime = time);
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (_selectedDate != null && _selectedTime != null) ? () {
                  Navigator.pop(context); // Close sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sample pickup scheduled successfully!'),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  setState(() {
                    for (var test in _tests) { test['selected'] = false; }
                    _selectedDate = null;
                    _selectedTime = null;
                  });
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Confirm Booking', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 16),
            ]
          ),
        );
      }
    );
  }

  Widget _buildDateTimePicker({required IconData icon, required String title, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
