import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Local notifications are not supported on the web.
    if (kIsWeb) return;
    tz.initializeTimeZones();

    // 👇 DEBUG: Saat dilimini yazdıralım
    print("📍 DEBUG: Cihazın Yerel Saati: ${DateTime.now()}");

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("🔔 DEBUG: Bildirime tıklandı: ${details.payload}");
      },
    );

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? granted = await androidImplementation
          ?.requestNotificationsPermission();
      print("🔐 DEBUG: Bildirim İzni Durumu: $granted");
    }
  }

  // --- 1. TASK İÇİN PLANLI BİLDİRİM (Mevcut Olan) ---
  Future<void> scheduleTaskNotification(
    int id,
    String taskTitle,
    DateTime dueDate,
  ) async {
    // Local notifications are not supported on the web.
    if (kIsWeb) return;
    final now = DateTime.now();
    DateTime scheduledTime = dueDate.subtract(const Duration(hours: 1));

    String messageBody =
        "Woof! 🚨 $taskTitle teslimine son 1 saat kaldı! Hadi bitirelim!";

    if (scheduledTime.isBefore(now)) {
      scheduledTime = now.add(const Duration(minutes: 1));
      messageBody = "Hav hav! 😱 $taskTitle için 1 saatten AZ kaldı! Acele et!";
    }

    if (scheduledTime.isBefore(now)) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'task_channel_final',
          'Task Reminders',
          channelDescription: 'Reminders for upcoming tasks',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      "Dikkat! Son 1 Saat! ⏳",
      messageBody,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("✅ PLANLANDI: $taskTitle için bildirim saati: $scheduledTime");
  }

  // --- 🔥 2. EKSİK OLAN KISIM: FOCUS İÇİN ANLIK BİLDİRİM ---
  // (Hata veren yer burasıydı, çünkü bu fonksiyon yoktu)
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    // Local notifications are not supported on the web.
    if (kIsWeb) return;
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'focus_channel_id', // Kanal ID
          'Focus Timer', // Kanal Adı
          channelDescription: 'Notifications for focus sessions',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // Anlık gösterim
    await flutterLocalNotificationsPlugin.show(
      888, // Sabit ID
      title,
      body,
      platformDetails,
    );
  }
}
