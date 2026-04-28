import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/daily_detail_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_service.dart';
import 'views/auth_gate.dart';
import 'views/splash_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'services/notification_service.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final notificationService = NotificationService();
  await notificationService.init();

  // เริ่มต้นภาษาไทยสำหรับ DateFormat
  await initializeDateFormatting('th_TH', null);
  
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
        ChangeNotifierProvider(create: (context) => SettingsViewModel(prefs)),
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
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // พื้นหลังแอปสีขาว
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white, // พื้นหลัง AppBar สีขาว
          foregroundColor: Colors.black,
        ),
      ),
      // เริ่มต้นด้วยหน้า Splash Screen
      home: const SplashView(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('th', 'TH'),
        Locale('en', 'US'),
      ],
      locale: const Locale('th', 'TH'),
    );
  }
}