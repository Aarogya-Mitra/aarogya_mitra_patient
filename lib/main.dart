import 'package:arogya_mitra_patient/constant/constants.dart';
import 'package:arogya_mitra_patient/firebase_options.dart';
import 'package:arogya_mitra_patient/routes/route_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: AppConstants.geminiApiKey);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: RoutePage());
  }
}
