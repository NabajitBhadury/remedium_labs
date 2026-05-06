class LabTest {
  final int id;
  final String name;
  final String type;
  final String sampleType;
  final String tat;
  final double mrp;
  final double? profitRate;
  final double? focoRate;
  final String status;

  LabTest({
    required this.id,
    required this.name,
    required this.type,
    required this.sampleType,
    required this.tat,
    required this.mrp,
    this.profitRate,
    this.focoRate,
    required this.status,
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      sampleType: json['sample_type']?.toString() ?? '',
      tat: json['tat']?.toString() ?? '',
      mrp: double.tryParse(json['mrp']?.toString() ?? '0') ?? 0.0,
      profitRate: double.tryParse(json['profit_rate']?.toString() ?? ''),
      focoRate: double.tryParse(json['foco_rate']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
    );
  }
}
