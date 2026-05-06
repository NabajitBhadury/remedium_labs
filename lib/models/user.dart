class User {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final int? age;
  final String gender;
  final String createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.age,
    required this.gender,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? ''),
      gender: json['gender']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'age': age,
        'gender': gender,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  User copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    int? age,
    String? gender,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
