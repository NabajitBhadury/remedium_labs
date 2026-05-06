class Franchise {
  final int id;
  final String franchiseId;
  final String name;
  final String address;
  final String city;
  final String pincode;
  final String contactNumber;
  final String whatsappNumber;
  final String email;
  final String category;
  final String status;

  Franchise({
    required this.id,
    required this.franchiseId,
    required this.name,
    required this.address,
    required this.city,
    required this.pincode,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.email,
    required this.category,
    required this.status,
  });

  factory Franchise.fromJson(Map<String, dynamic> json) {
    return Franchise(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      franchiseId: json['franchise_id']?.toString() ?? '',
      name: json['franchise_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  /// Convert to the legacy Lab shape for backward compatibility with BookingFlowScreen
  String get displayAddress => city.isNotEmpty ? '$address, $city' : address;
}
