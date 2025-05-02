import 'package:arogya_mitra_patient/auth/login_page.dart';
import 'package:arogya_mitra_patient/database/firebase_db.dart';
import 'package:arogya_mitra_patient/models/patient_profile.dart';
import 'package:arogya_mitra_patient/pages/consultation_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PatientProfile? patientProfile;

  void getPatientProfile() async {
    patientProfile = await FirebaseDb.getPatientProfile(
      FirebaseDb.auth.currentUser?.uid ?? '',
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getPatientProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.blueGrey,
                  ),
                  title: Text(
                    'Welcome, ${patientProfile?.name ?? "Patient"}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Email: ${FirebaseDb.auth.currentUser?.email ?? "Not available"}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await FirebaseDb.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.health_and_safety_outlined,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Need medical consultation?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Connect with a doctor by starting a new consultation',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // 🔥 Start Consultation Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ConsultationPage()),
                  );
                },
                icon: const Icon(Icons.chat_outlined),
                label: const Text('START CONSULTATION'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 16),

              // 🔥 Your Prescriptions Button
              ElevatedButton.icon(
                onPressed: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const ReminderScreen(),
                  //   ),
                  // );
                },
                icon: const Icon(Icons.medical_services_outlined),
                label: const Text('YOUR PRESCRIPTIONS'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // 🔥 Past Consultations Button
              ElevatedButton.icon(
                onPressed: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const PastConsultationsScreen(),
                  //   ),
                  // );
                },
                icon: const Icon(Icons.history),
                label: const Text('PAST CONSULTATIONS'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
