
class PrescriptionModel {
  final List<Map<String, dynamic>> medicines; // Medicine name with timings
  final List<String> labTests;

  PrescriptionModel({
    required this.medicines,
    required this.labTests,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> medicinesList = [];
    if (json['medicines'] != null) {
      (json['medicines'] as List).forEach((medicine) {
        if (medicine is Map<String, dynamic>) {
          medicinesList.add(medicine);
        }
      });
    }

    return PrescriptionModel(
      medicines: medicinesList,
      labTests: json['labTests'] != null ? List<String>.from(json['labTests']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicines': medicines,
      'labTests': labTests,
    };
  }
}