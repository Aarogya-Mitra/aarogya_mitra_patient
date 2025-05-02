class PatientProfile {
  final String userId;
  final String name;
  final String age;
  final String gender;

  PatientProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
  });

  // Convert a PatientProfile to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'age': age,
      'gender': gender,
    };
  }

  // Create a PatientProfile from a Firestore Map
  factory PatientProfile.fromMap(Map<String, dynamic> map) {
    return PatientProfile(
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
    );
  }
}
