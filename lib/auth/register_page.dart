import 'package:arogya_mitra_patient/database/firebase_db.dart';
import 'package:arogya_mitra_patient/models/patient_profile.dart';
import 'package:arogya_mitra_patient/pages/home_page.dart';
import 'package:arogya_mitra_patient/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  String email = '';
  String password = '';
  String name = '';
  String age = '';
  String gender = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ageController,
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: genderController,
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                CustomDialog.showLoadingDialog(
                  context,
                  message: 'Registering...',
                );
                email = emailController.text;
                password = passwordController.text;
                name = nameController.text;
                age = ageController.text;
                gender = genderController.text;

                if (email.isEmpty ||
                    password.isEmpty ||
                    name.isEmpty ||
                    age.isEmpty ||
                    gender.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                FirebaseDb.signUpWithEmailAndPassword(email, password).then((
                  value,
                ) {
                  PatientProfile patientProfile = PatientProfile(
                    userId: FirebaseDb.auth.currentUser!.uid,
                    name: name,
                    age: age,
                    gender: gender,
                  );

                  FirebaseDb.addPatientProfile(profile: patientProfile).then((
                    _,
                  ) {
                    CustomDialog.hideLoadingDialog(context);
                    if (value == false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration Failed')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Registration Successful'),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    }
                  });
                });
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
