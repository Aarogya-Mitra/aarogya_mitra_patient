import 'package:arogya_mitra_patient/auth/login_page.dart';
import 'package:arogya_mitra_patient/database/firebase_db.dart';
import 'package:arogya_mitra_patient/pages/home_page.dart';
import 'package:flutter/material.dart';

class RoutePage extends StatelessWidget {
  const RoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    if(FirebaseDb.auth.currentUser != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}