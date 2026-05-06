import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class CouponResult {
  final String couponCode;
  final double orderAmount;
  final double discount;
  final double finalAmount;

  CouponResult({
    required this.couponCode,
    required this.orderAmount,
    required this.discount,
    required this.finalAmount,
  });
}

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;
  int? _cachedUserId;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // ─── Fetch Bookings ────────────────────────────────────────────────────────

  Future<void> fetchBookings({
    required int userId,
    String? status,
    String? search,
  }) async {
    _cachedUserId = userId;
    _isLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.getBookings(
        userId: userId,
        status: status,
        search: search,
      );
      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>? ?? [];
        _bookings = data
            .map((e) => Booking.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('getBookings error: ${result['message']}');
        _bookings = [];
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      _bookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Create Booking ────────────────────────────────────────────────────────

  /// Returns booking data on success or throws a String error.
  Future<Map<String, dynamic>> createBooking({
    required String serviceType,
    required String labId,
    required String userId,
    required String patientName,
    required String patientPhone,
    required String testId,
    required double amount,
    required double finalAmount,
    String? patientGender,
    String? patientAddress,
    String? bookingDate,
    String? bookingTime,
    String? testName,
    String? franchiseId,
    String? franchiseName,
    String? referringDoctor,
    double? discount,
    String? couponCode,
    String? paymentMode,
  }) async {
    final result = await ApiService.createBooking(
      serviceType: serviceType,
      labId: labId,
      userId: userId,
      patientName: patientName,
      patientPhone: patientPhone,
      testId: testId,
      amount: amount,
      finalAmount: finalAmount,
      createdById: userId, // Creator is the User
      patientGender: patientGender,
      patientAddress: patientAddress,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      testName: testName,
      franchiseId: franchiseId,
      franchiseName: franchiseName,
      referringDoctor: referringDoctor,
      discount: discount,
      couponCode: couponCode,
      paymentMode: paymentMode,
    );

    if (result['success'] == true) {
      // Refresh bookings list in background
      if (_cachedUserId != null) fetchBookings(userId: _cachedUserId!);
      return result['data'] as Map<String, dynamic>;
    }
    throw result['message']?.toString() ?? 'Booking failed';
  }

  // ─── Apply Coupon ──────────────────────────────────────────────────────────

  /// Returns [CouponResult] on success or throws a String error message.
  Future<CouponResult> applyCoupon({
    required String couponCode,
    required double orderAmount,
  }) async {
    final result = await ApiService.applyCoupon(
      couponCode: couponCode,
      orderAmount: orderAmount,
    );

    if (result['success'] == true) {
      final data = (result.containsKey('data') && result['data'] is Map)
          ? result['data'] as Map<String, dynamic>
          : result;
      return CouponResult(
        couponCode: data['coupon_code']?.toString() ?? couponCode,
        orderAmount:
            double.tryParse(data['order_amount']?.toString() ?? '') ??
            orderAmount,
        discount: double.tryParse(data['discount']?.toString() ?? '') ?? 0.0,
        finalAmount:
            double.tryParse(data['final_amount']?.toString() ?? '') ??
            orderAmount,
      );
    }
    throw result['message']?.toString() ?? 'Invalid coupon';
  }

  // ─── Cancel Booking ────────────────────────────────────────────────────────

  /// Cancels a booking. Returns null on success or an error String.
  Future<String?> cancelBooking({
    required int bookingId,
    required int userId,
  }) async {
    final result = await ApiService.cancelBooking(
      bookingId: bookingId,
      userId: userId,
    );
    if (result['success'] == true) {
      // Update local list optimistically
      final idx = _bookings.indexWhere((b) => b.id == bookingId.toString());
      if (idx != -1) {
        // Re-fetch to get fresh status from server
        if (_cachedUserId != null) fetchBookings(userId: _cachedUserId!);
      }
      return null;
    }
    return result['message']?.toString() ?? 'Cancellation failed';
  }

  // ─── View Booking ──────────────────────────────────────────────────────────

  /// Fetches a single booking's detail. Returns the data map or throws String.
  Future<Map<String, dynamic>> viewBooking({
    required int bookingId,
    required int userId,
  }) async {
    final result = await ApiService.viewBooking(
      bookingId: bookingId,
      userId: userId,
    );
    if (result['success'] == true) {
      return result['data'] as Map<String, dynamic>;
    }
    throw result['message']?.toString() ?? 'Booking not found';
  }
}
