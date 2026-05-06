import 'package:flutter/material.dart';

enum BookingStatus { pending, confirmed, completed, cancelled }

class Booking {
  final String id;
  final String labName;
  final String serviceName;
  final DateTime date;
  final TimeOfDay time;
  final BookingStatus status;
  final String patientName;

  // API fields
  final String? bookingToken;
  final double? finalAmount;
  final double? discount;
  final String? couponCode;
  final String? paymentMode;
  final String? bookingType;
  final String? patientMobile;
  final int? patientAge;
  final String? patientGender;
  final double? originalAmount;
  final String? reffDoc;

  Booking({
    required this.id,
    required this.labName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.status,
    required this.patientName,
    this.bookingToken,
    this.finalAmount,
    this.discount,
    this.couponCode,
    this.paymentMode,
    this.bookingType,
    this.patientMobile,
    this.patientAge,
    this.patientGender,
    this.originalAmount,
    this.reffDoc,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parse status
    BookingStatus parsedStatus;
    switch (json['status']?.toString().toLowerCase()) {
      case 'confirmed':
        parsedStatus = BookingStatus.confirmed;
        break;
      case 'completed':
        parsedStatus = BookingStatus.completed;
        break;
      case 'cancelled':
        parsedStatus = BookingStatus.cancelled;
        break;
      default:
        parsedStatus = BookingStatus.pending;
    }

    // Parse date, defaulting to now if missing/null
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toString(),
      );
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return Booking(
      id: json['id']?.toString() ?? '',
      labName: json['franchise_name']?.toString() ?? '',
      serviceName: json['test_name']?.toString() ?? '',
      date: parsedDate,
      time: TimeOfDay(
        hour: parsedDate.hour,
        minute: parsedDate.minute,
      ),
      status: parsedStatus,
      patientName: json['patient_name']?.toString() ?? '',
      bookingToken: json['booking_token']?.toString(),
      finalAmount: double.tryParse(json['final_amount']?.toString() ?? ''),
      discount: double.tryParse(json['discount']?.toString() ?? ''),
      couponCode: json['coupon_code']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      bookingType: json['booking_type']?.toString(),
      patientMobile: json['patient_mobile']?.toString(),
      patientAge: int.tryParse(json['patient_age']?.toString() ?? ''),
      patientGender: json['patient_gender']?.toString(),
      originalAmount: double.tryParse(json['amount']?.toString() ?? ''),
      reffDoc: json['reff_doc']?.toString(),
    );
  }
}
