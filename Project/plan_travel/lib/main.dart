import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/daily_detail_viewmodel.dart';
import 'views/splash_view.dart';

void main() {
  runApp(
    // หุ้มแอปด้วย Provider เพื่อให้ทุกหน้าเรียกใช้ ViewModel ได้
    ChangeNotifierProvider(
      create: (context) => DailyDetailViewModel(),
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