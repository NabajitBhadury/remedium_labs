import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://old.indomitechgroup.com/testing/remedium-labs/api';

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, String> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _get(
    String endpoint, [
    Map<String, String>? params,
  ]) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/$endpoint',
      ).replace(queryParameters: params);
      final response = await http.get(uri);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─── Authentication ────────────────────────────────────────────────────────

  /// POST /user/login
  /// [identifier] can be a phone number or email address
  static Future<Map<String, dynamic>> login(
    String identifier,
    String password,
  ) async {
    return _post('user/login', {'identifier': identifier, 'password': password});
  }

  /// POST /user/register
  static Future<Map<String, dynamic>> register(
    String name,
    String phone,
    String email,
    int age,
    String gender,
    String password,
  ) async {
    return _post('user/register', {
      'name': name,
      'phone': phone,
      'email': email,
      'age': age.toString(),
      'gender': gender,
      'password': password,
    });
  }

  // ─── User Profile ──────────────────────────────────────────────────────────

  /// POST /user/profile — fetch profile by user_id
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    return _post('user/profile', {'user_id': userId.toString()});
  }

  /// POST /user/update_profile
  static Future<Map<String, dynamic>> updateProfile(
    int userId, {
    String? name,
    String? phone,
    String? gender,
  }) async {
    final body = <String, String>{'user_id': userId.toString()};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (gender != null && gender.isNotEmpty) body['gender'] = gender;
    return _post('user/update_profile', body);
  }

  // ─── Family Members ────────────────────────────────────────────────────────

  /// POST /user/add_family_member
  static Future<Map<String, dynamic>> addFamilyMember({
    required int userId,
    required String name,
    required String relation,
    required String gender,
    required int age,
    required String phone,
  }) async {
    return _post('user/add_family_member', {
      'user_id': userId.toString(),
      'name': name,
      'relation': relation,
      'gender': gender,
      'age': age.toString(),
      'phone': phone,
    });
  }

  /// GET /user/get_family_members?user_id=X
  static Future<Map<String, dynamic>> getFamilyMembers(int userId) async {
    return _get('user/get_family_members', {'user_id': userId.toString()});
  }

  /// POST /user/delete_family_member
  static Future<Map<String, dynamic>> deleteFamilyMember({
    required int memberId,
    required int userId,
  }) async {
    return _post('user/delete_family_member', {
      'id': memberId.toString(),
      'user_id': userId.toString(),
    });
  }

  // ─── Tests ─────────────────────────────────────────────────────────────────

  /// GET /user/get_tests?page=X&limit=Y
  static Future<Map<String, dynamic>> getTests({
    int page = 1,
    int limit = 100,
  }) async {
    return _get('user/get_tests', {
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  // ─── Bookings ──────────────────────────────────────────────────────────────

  /// POST /user/create_booking
  static Future<Map<String, dynamic>> createBooking({
    required String serviceType,
    required String labId,
    required String userId,
    required String patientName,
    required String patientPhone,
    required String testId,
    required double amount,
    required double finalAmount,
    required String createdById,
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
    final body = <String, String>{
      'service_type': serviceType,
      'lab_id': labId,
      'user_id': userId,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'test_id': testId,
      'amount': amount.toString(),
      'final_amount': finalAmount.toString(),
      'created_by_type': 'User',
      'created_by_id': createdById,
    };
    if (patientGender != null && patientGender.isNotEmpty) body['patient_gender'] = patientGender;
    if (patientAddress != null && patientAddress.isNotEmpty) body['patient_address'] = patientAddress;
    if (bookingDate != null && bookingDate.isNotEmpty) body['booking_date'] = bookingDate;
    if (bookingTime != null && bookingTime.isNotEmpty) body['booking_time'] = bookingTime;
    if (testName != null && testName.isNotEmpty) body['test_name'] = testName;
    if (franchiseId != null && franchiseId.isNotEmpty) body['franchise_id'] = franchiseId;
    if (franchiseName != null && franchiseName.isNotEmpty) body['franchise_name'] = franchiseName;
    if (referringDoctor != null && referringDoctor.isNotEmpty) body['referring_doctor'] = referringDoctor;
    if (discount != null) body['discount'] = discount.toString();
    if (couponCode != null && couponCode.isNotEmpty) body['coupon_code'] = couponCode;
    if (paymentMode != null && paymentMode.isNotEmpty) body['payment_mode'] = paymentMode;

    return _post('user/create_booking', body);
  }

  /// GET /user/get_bookings
  static Future<Map<String, dynamic>> getBookings({
    required int userId,
    int page = 1,
    int limit = 50,
    String? status,
    String? search,
  }) async {
    final params = <String, String>{
      'user_id': userId.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;
    return _get('user/get_bookings', params);
  }

  // ─── Coupons ───────────────────────────────────────────────────────────────

  /// POST /user/apply_coupon
  static Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    required double orderAmount,
  }) async {
    return _post('user/apply_coupon', {
      'coupon_code': couponCode,
      'order_amount': orderAmount.toString(),
    });
  }

  // ─── Cancel & View Booking ─────────────────────────────────────────────────

  /// POST /user/cancel_booking
  static Future<Map<String, dynamic>> cancelBooking({
    required int bookingId,
    required int userId,
  }) async {
    return _post('user/cancel_booking', {
      'id': bookingId.toString(),
      'user_id': userId.toString(),
    });
  }

  /// GET /user/view_booking?id=X&user_id=Y
  static Future<Map<String, dynamic>> viewBooking({
    required int bookingId,
    required int userId,
  }) async {
    return _get('user/view_booking', {
      'id': bookingId.toString(),
      'user_id': userId.toString(),
    });
  }

  // ─── Franchises (Labs) ─────────────────────────────────────────────────────

  /// GET /user/get_all_franchise
  static Future<Map<String, dynamic>> getAllFranchises({
    int page = 1,
    int limit = 50,
    String? q,
    String? city,
    String? category,
    String? pincode,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (pincode != null && pincode.isNotEmpty) params['pincode'] = pincode;
    return _get('user/get_all_franchise', params);
  }

  /// GET /user/view_franchise?id=FR001
  static Future<Map<String, dynamic>> viewFranchise(String franchiseId) async {
    return _get('user/view_franchise', {'id': franchiseId});
  }
}
