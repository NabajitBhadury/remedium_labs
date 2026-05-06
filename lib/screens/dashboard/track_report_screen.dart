import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class TrackReportScreen extends StatefulWidget {
  const TrackReportScreen({super.key});

  @override
  State<TrackReportScreen> createState() => _TrackReportScreenState();
}

class _TrackReportScreenState extends State<TrackReportScreen> {
  final TextEditingController _trackingController = TextEditingController();
  bool _isTracking = false;

  final List<Map<String, dynamic>> _timelineSteps = [
    {'title': 'Booking Confirmed', 'subtitle': '24 Oct, 09:30 AM', 'isCompleted': true, 'isActive': false},
    {'title': 'Sample Collected', 'subtitle': '24 Oct, 11:00 AM', 'isCompleted': true, 'isActive': false},
    {'title': 'Sample Reached Lab', 'subtitle': '24 Oct, 02:15 PM', 'isCompleted': true, 'isActive': false},
    {'title': 'Testing in Progress', 'subtitle': 'Currently under analysis by our experts.', 'isCompleted': false, 'isActive': true},
    {'title': 'Report Ready', 'subtitle': 'Expected by 25 Oct, 08:00 AM', 'isCompleted': false, 'isActive': false},
  ];

  final List<Map<String, String>> _recentActiveTests = [
    {'id': 'LPK-84931', 'name': 'Complete Blood Count', 'status': 'Testing in Progress', 'date': '24 Oct'},
    {'id': 'LPK-84932', 'name': 'Lipid Profile', 'status': 'Sample Collected', 'date': '24 Oct'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Track Your Report',
          style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            const SizedBox(height: 32),
            if (_isTracking) 
              _buildTrackingTimeline()
            else 
              _buildRecentTests(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Track Status",
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter your tracking ID or registered mobile number to check the current status of your reports.",
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _trackingController,
              decoration: InputDecoration(
                hintText: "e.g., LPK-12345",
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.tag, color: AppTheme.primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_trackingController.text.isNotEmpty) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isTracking = true;
                  });
                }
              },
              child: Text(
                "Track Now",
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildRecentTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Active Tests",
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 16),
        ..._recentActiveTests.map((test) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.science, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(test['name']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(test['id']!, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text("•", style: TextStyle(color: Colors.grey.shade400)),
                        const SizedBox(width: 8),
                        Text(test['date']!, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _trackingController.text = test['id']!;
                  setState(() {
                    _isTracking = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(20)),
                  child: Text("Track", style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              )
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideX()),
      ],
    );
  }

  Widget _buildTrackingTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tracking Result",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isTracking = false;
                  _trackingController.clear();
                });
              },
              child: Text(
                "Clear Result",
                style: GoogleFonts.inter(color: Colors.red.shade400, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            children: List.generate(_timelineSteps.length, (index) {
              final step = _timelineSteps[index];
              final isLast = index == _timelineSteps.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Line & Dot
                    Column(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: step['isCompleted'] 
                                ? Colors.green 
                                : (step['isActive'] ? AppTheme.primaryColor : Colors.grey.shade100),
                            shape: BoxShape.circle,
                            border: step['isActive'] ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 6) : null,
                          ),
                          child: step['isCompleted']
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : (step['isActive'] 
                                  ? const Icon(Icons.circle, size: 8, color: Colors.white)
                                  : null),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: step['isCompleted'] ? Colors.green : Colors.grey.shade200,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Timeline Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'],
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: step['isActive'] || step['isCompleted'] ? FontWeight.bold : FontWeight.w500,
                                color: step['isActive'] 
                                    ? AppTheme.primaryColor 
                                    : (step['isCompleted'] ? AppTheme.textPrimary : Colors.grey.shade500),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step['subtitle'],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: step['isActive'] ? AppTheme.textPrimary : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (200 + (index * 100)).ms).slideX(begin: 0.1);
            }),
          ),
        ),
      ],
    ).animate().fadeIn();
  }
}
