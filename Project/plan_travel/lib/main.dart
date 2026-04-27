import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/daily_detail_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/splash_view.dart';

import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // โหลดค่า Environment (.env)
  await dotenv.load(fileName: "assets/env");

  // เริ่มต้น Firebase
  try {
    await Firebase.initializeApp();
    print("Firebase Initialized Successfully");
  } catch (e) {
    print("Firebase Initialization Error: $e");
  }

  final firebaseService = FirebaseService();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: firebaseService),
        ChangeNotifierProvider(create: (context) => DailyDetailViewModel(firebaseService)),
        ChangeNotifierProvider(create: (context) => ProfileViewModel(firebaseService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plan Travel',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const SplashView(),
    );
  }
}