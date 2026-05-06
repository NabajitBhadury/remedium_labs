import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/loader_provider.dart';
import '../../models/booking.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        context.read<LoaderProvider>().showLoader();
        await context.read<BookingProvider>().fetchBookings(userId: auth.userId ?? 0);
        if (mounted) context.read<LoaderProvider>().hideLoader();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return _buildUnauthenticatedState(context);
    }

    final bookings = context.watch<BookingProvider>().bookings;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              context.read<LoaderProvider>().showLoader();
              await context.read<BookingProvider>().fetchBookings(
                userId: context.read<AuthProvider>().userId ?? 0,
              );
              if (mounted) context.read<LoaderProvider>().hideLoader();
            },
          ),
        ],
      ),
      body: bookings.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _buildAppointmentCard(context, booking, index);
              },
            ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                  FontAwesomeIcons.calendarCheck,
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.calendarXmark,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No appointments yet",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    Booking booking,
    int index,
  ) {
    final dateFormatDay = DateFormat('dd');
    final dateFormatMonth = DateFormat('MMM');
    final timeFormat = DateFormat('hh:mm a');

    // Parse time if it were a DateTime, but here it is TimeOfDay.
    // We will just format manually or construct a DateTime
    final dt = DateTime(
      booking.date.year,
      booking.date.month,
      booking.date.day,
      booking.time.hour,
      booking.time.minute,
    );

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),            onTap: () {              _showBookingDetails(context, booking);
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Column
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              dateFormatDay.format(booking.date),
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              dateFormatMonth.format(booking.date).toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.serviceName,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  booking.labName,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  timeFormat.format(dt),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(booking.status),
                      if (booking.status == BookingStatus.completed)
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text("Report"),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                      else if (booking.status == BookingStatus.pending)
                        TextButton(
                          onPressed: () => _handleCancel(context, booking),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text("Cancel"),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
    }
  
    Widget _buildStatusChip(BookingStatus status) {
      Color color;
      IconData icon;
      String label;
  
      switch (status) {
        case BookingStatus.pending:
          color = Colors.green;
          icon = Icons.hourglass_top_rounded;
          label = 'Pending';
          break;
        case BookingStatus.confirmed:
          color = AppTheme.primaryColor;
          icon = Icons.check_circle_outline_rounded;
          label = 'Confirmed';
          break;
        case BookingStatus.completed:
          color = Colors.green.shade700;
          icon = Icons.task_alt_rounded;
          label = 'Completed';
          break;
        case BookingStatus.cancelled:
          color = AppTheme.errorColor;
          icon = Icons.cancel_outlined;
          label = 'Cancelled';
          break;
      }
  
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  void _showBookingDetails(BuildContext context, Booking booking) {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingDetailsSheet(
        bookingId: int.tryParse(booking.id) ?? 0,
        userId: userId,
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context, Booking booking) async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    context.read<LoaderProvider>().showLoader();
    try {
      final error = await context.read<BookingProvider>().cancelBooking(
            bookingId: int.tryParse(booking.id) ?? 0,
            userId: userId,
          );
      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) context.read<LoaderProvider>().hideLoader();
    }
  }
}

class _BookingDetailsSheet extends StatefulWidget {
  final int bookingId;
  final int userId;

  const _BookingDetailsSheet({required this.bookingId, required this.userId});

  @override
  State<_BookingDetailsSheet> createState() => _BookingDetailsSheetState();
}

class _BookingDetailsSheetState extends State<_BookingDetailsSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
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
            'Booking Details',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: context.read<BookingProvider>().viewBooking(
                    bookingId: widget.bookingId,
                    userId: widget.userId,
                  ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Text(
                      'Failed to load details',
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  );
                }

                final data = snapshot.data!;
                return ListView(
                  children: [
                    _buildDetailRow('Booking Token', data['booking_id']?.toString() ?? data['booking_token']?.toString() ?? 'N/A', true),
                    _buildDetailRow('Test Name', data['test_name']?.toString() ?? 'N/A'),
                    _buildDetailRow('Service Type', data['service_type']?.toString() ?? 'N/A'),
                    _buildDetailRow('Lab', data['franchise_name']?.toString() ?? 'N/A'),
                    _buildDetailRow('Patient', data['patient_name']?.toString() ?? 'N/A'),
                    _buildDetailRow('Phone', data['patient_phone']?.toString() ?? data['patient_mobile']?.toString() ?? 'N/A'),
                    _buildDetailRow('Gender', data['patient_gender']?.toString() ?? 'N/A'),
                    if (data['patient_address'] != null)
                      _buildDetailRow('Address', data['patient_address'].toString()),
                    _buildDetailRow('Verification Code', data['verification_code']?.toString() ?? 'N/A'),
                    _buildDetailRow('Date', data['booking_date']?.toString() ?? 'N/A'),
                    _buildDetailRow('Time', data['booking_time']?.toString() ?? 'N/A'),
                    const Divider(height: 32),
                    _buildDetailRow('Original Amount', '₹${data['amount']?.toString() ?? '0'}'),
                    if (data['discount'] != null && data['discount'].toString() != '0' && data['discount'].toString() != '0.0')
                      _buildDetailRow('Discount', '-₹${data['discount']}'),
                    if (data['coupon_code'] != null && data['coupon_code'].toString().isNotEmpty)
                      _buildDetailRow('Coupon', data['coupon_code'].toString()),
                    _buildDetailRow('Final Amount', '₹${data['final_amount']?.toString() ?? '0'}', true),
                      _buildDetailRow('Payment Mode', (data['payment_mode'] as String?)?.toUpperCase() ?? 'N/A'),
                    _buildDetailRow('Payment Status', data['payment_status']?.toString() ?? 'N/A'),
                    _buildDetailRow('Booking Status', data['status']?.toString() ?? 'N/A', true),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Close', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [bool isHighlight = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                color: isHighlight ? AppTheme.primaryColor : Colors.black87,
                fontSize: 16,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
