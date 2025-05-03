import 'package:arogya_mitra_patient/models/consultation.dart';
import 'package:arogya_mitra_patient/models/patient_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDb {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<void> addPatientProfile({required PatientProfile profile}) async {
    try {
      await firestore.collection('patient_profile').doc(profile.userId).set({
        'user_id': profile.userId,
        'name': profile.name,
        'age': profile.age,
        'gender': profile.gender,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<PatientProfile?> getPatientProfile(String userId) async {
    try {
      DocumentSnapshot doc = await firestore.collection('patient_profile').doc(userId).get();
      if (doc.exists) {
        return PatientProfile.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<String?> createConsultation(Consultation consultation) async {
    try {
      final json = consultation.toJson();
      json.remove('id'); // Firestore generates the ID
      DocumentReference docRef = await firestore.collection('consultations').add(json);
      return docRef.id;
    } catch (e) {
      print("Error creating consultation: ${e.toString()}");
      return null;
    }
  }
}
