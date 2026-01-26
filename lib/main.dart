import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- SERVİSLER ---
import 'services/notification_service.dart';

// --- PROVIDER'LAR (BEYİNLER) ---
import 'providers/pet_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/course_provider.dart'; // 👈 1. BU IMPORT EKSİKTİ

// --- EKRANLAR ---
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => FocusProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        // 👇 2. BURASI EKSİKTİ: CourseProvider'ı sisteme tanıtıyoruz
        // Eğer loadCourses fonksiyonun varsa açılışta verileri çekmesi için ..loadCourses() ekleyebilirsin
        ChangeNotifierProvider(create: (_) => CourseProvider()..loadCourses()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Pet',
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Light Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),

      // Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      home: const DashboardScreen(),
    );
  }
}
