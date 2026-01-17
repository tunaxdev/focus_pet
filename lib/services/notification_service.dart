import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
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
      // 👇 Bildirime tıklayınca ne olacağını görmek için
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

  Future<void> scheduleTaskNotification(
    int id,
    String taskTitle,
    DateTime dueDate,
  ) async {
    final now = DateTime.now();

    // GERÇEK MANTIK: Teslim tarihinden 1 saat önce
    DateTime scheduledTime = dueDate.subtract(const Duration(hours: 1));

    String messageBody =
        "Woof! 🚨 $taskTitle teslimine son 1 saat kaldı! Hadi bitirelim!";

    // Eğer kullanıcı ödevi zaten "son 1 saat kala" eklediyse (Örn: Ödev 30 dk sonra)
    // Bildirimi kaçırmaması için hemen 1 dakika sonraya kuralım.
    if (scheduledTime.isBefore(now)) {
      scheduledTime = now.add(const Duration(minutes: 1));
      messageBody = "Hav hav! 😱 $taskTitle için 1 saatten AZ kaldı! Acele et!";
    }

    // Geçmiş zamana (örneğin düne) bildirim kurulmaz
    if (scheduledTime.isBefore(now)) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'task_channel_final', // Kanal ID'si sabitlendi
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
}
