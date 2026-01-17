import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'services/notification_service.dart'; // 👇 Servisi import ettik

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 Bildirim servisini başlatıyoruz
  await NotificationService().init();

  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    FocusPetApp(
      startScreen: seenOnboarding
          ? const DashboardScreen()
          : const OnboardingScreen(),
    ),
  );
}

class FocusPetApp extends StatelessWidget {
  final Widget startScreen;

  const FocusPetApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusPet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      home: startScreen,
    );
  }
}
