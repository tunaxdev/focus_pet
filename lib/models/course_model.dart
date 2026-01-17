import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String title;
  bool isCompleted;
  final DateTime? dueDate;

  TaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
  });

  // 👇 JSON'dan Model üretme (Okuma)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  // 👇 Modeli JSON'a çevirme (Kaydetme)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}

class CourseSchedule {
  final int dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;

  CourseSchedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  // TimeOfDay'i JSON'da saklamak için "14:30" gibi string yapıyoruz
  // veya "hour" ve "minute" olarak ayırıyoruz. En garantisi dakika/saat saklamaktır.

  factory CourseSchedule.fromJson(Map<String, dynamic> json) {
    return CourseSchedule(
      dayOfWeek: json['dayOfWeek'],
      startTime: TimeOfDay(
        hour: json['startHour'],
        minute: json['startMinute'],
      ),
      endTime: TimeOfDay(hour: json['endHour'], minute: json['endMinute']),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'location': location,
    };
  }

  String get timeRange {
    final start =
        '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
}

class CourseModel {
  final String id;
  final String name;
  final Color color;
  List<TaskModel> relatedTasks;
  final List<CourseSchedule> schedules;

  CourseModel({
    required this.id,
    required this.name,
    required this.color,
    List<TaskModel>? relatedTasks,
    this.schedules = const [],
  }) : relatedTasks = relatedTasks ?? [];

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      name: json['name'],
      // Rengi integer (sayı) olarak saklayıp geri çeviriyoruz
      color: Color(json['color']),
      relatedTasks: (json['relatedTasks'] as List<dynamic>)
          .map((e) => TaskModel.fromJson(e))
          .toList(),
      schedules: (json['schedules'] as List<dynamic>)
          .map((e) => CourseSchedule.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.toARGB32(), // Rengi sayıya çevir
      'relatedTasks': relatedTasks.map((t) => t.toJson()).toList(),
      'schedules': schedules.map((s) => s.toJson()).toList(),
    };
  }
}
