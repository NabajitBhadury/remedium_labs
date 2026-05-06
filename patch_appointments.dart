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
                    _buildDetailRow('Payment Mode', data['payment_mode']?.toString()?.toUpperCase() ?? 'N/A'),
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
