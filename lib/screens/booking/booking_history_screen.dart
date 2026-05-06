import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../providers/loader_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
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

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return _buildUnauthenticatedState(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
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
      body: _buildBookingList(),
    );
  }

  Widget _buildBookingList() {
    final bookingProvider = context.watch<BookingProvider>();

    if (bookingProvider.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your test bookings will appear here.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookingProvider.bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final booking = bookingProvider.bookings[index];
        final isCompleted = booking.status == BookingStatus.completed;
        final statusColor = _getStatusColor(booking.status);

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.local_hospital_outlined,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  booking.labName,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  booking.status.name.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.serviceName,
                            style: GoogleFonts.inter(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Booking token
                          if (booking.bookingToken != null)
                            Text(
                              booking.bookingToken!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, yyyy').format(booking.date),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (booking.bookingType != null) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  booking.bookingType == 'Home'
                                      ? Icons.home
                                      : Icons.apartment,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.bookingType!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show discount info if coupon was applied
                        if (booking.couponCode != null &&
                            booking.couponCode!.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(Icons.local_offer,
                                  size: 13, color: Colors.green.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${booking.couponCode} · -₹${booking.discount?.toStringAsFixed(0) ?? '0'}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          'Total Amount',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '₹${(booking.finalAmount ?? booking.originalAmount ?? 0).toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // Action button
                    if (isCompleted)
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Downloading Invoice...'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.05),
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: Text(
                          'Invoice',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      )
                    else if (booking.status == BookingStatus.pending ||
                        booking.status == BookingStatus.confirmed)
                      TextButton.icon(
                        onPressed: () => _confirmCancelBooking(
                          context,
                          bookingId: int.tryParse(booking.id) ?? 0,
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.06),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: Text(
                          'Cancel',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      Text(
                        booking.paymentMode ?? '',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
      },
    );
  }

  Future<void> _confirmCancelBooking(
    BuildContext context, {
    required int bookingId,
  }) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Booking',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to cancel this booking?',
          style: GoogleFonts.inter(color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep',
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Cancel Booking',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    context.read<LoaderProvider>().showLoader();
    final error = await context.read<BookingProvider>().cancelBooking(
          bookingId: bookingId,
          userId: auth.userId ?? 0,
        );
    if (mounted) context.read<LoaderProvider>().hideLoader();

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Widget _buildUnauthenticatedState(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.history_edu,
                  size: 64,
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'View Your History',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              Text(
                'Login to access your past bookings, payments,\nand download reports.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
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
                label: const Text('Login Now'),
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
}
