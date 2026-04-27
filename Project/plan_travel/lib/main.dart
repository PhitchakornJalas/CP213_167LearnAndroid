import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/daily_detail_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // โหลดค่า Environment (.env)
  await dotenv.load(fileName: "assets/env");

  // --- โค้ดสำหรับล้างข้อมูล SharedPreferences (ลบหลังจากรันแล้ว) ---
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print("SharedPreferences cleared!");
  // ---------------------------------------------------------

  // เริ่มต้น Firebase (ต้องทำหลังจาก WidgetsFlutterBinding.ensureInitialized())
  try {
    await Firebase.initializeApp();
    print("Firebase Initialized Successfully");
  } catch (e) {
    print("Firebase Initialization Error: $e");
    // ในขั้นตอนนี้ ถ้ายังไม่ได้ใส่ google-services.json มันจะ error
    // แต่เราเขียนโครงไว้ก่อนตามที่ user ต้องการ
  }

  runApp(
    // หุ้มแอปด้วย MultiProvider เพื่อรองรับหลาย ViewModel
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DailyDetailViewModel()),
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),
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