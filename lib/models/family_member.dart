class FamilyMember {
  final String id;
  final String name;
  final String relation; // Spouse, Son, Daughter, Parent, Sibling, Other
  final String phone;
  final String gender;
  final String age; // kept as String for UI compatibility

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    required this.gender,
    required this.age,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      relation: json['relation']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
    );
  }
}
