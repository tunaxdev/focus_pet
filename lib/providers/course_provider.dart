import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/course_model.dart'; // Model dosyanın yolu

class CourseProvider with ChangeNotifier {
  List<CourseModel> _courses = [];
  bool _isLoading = true;

  // Verileri dışarıya açıyoruz (Getter)
  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;

  // 1. Verileri Yükle
  Future<void> loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesJson = prefs.getString('saved_courses');

    if (coursesJson != null) {
      final List<dynamic> decodedList = jsonDecode(coursesJson);
      _courses = decodedList.map((e) => CourseModel.fromJson(e)).toList();
    }
    _isLoading = false;
    notifyListeners(); // 🔔 Ekranlara "Veri geldi, yenilenin!" der
  }

  // 2. Verileri Telefona Kaydet (Gizli Fonksiyon)
  Future<void> _persistCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      _courses.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('saved_courses', encodedList);
  }

  // 3. Ders Ekle veya Güncelle
  void saveCourse(CourseModel course) {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course; // Güncelle
    } else {
      _courses.add(course); // Yeni Ekle
    }
    _persistCourses();
    notifyListeners(); // 🔔 Ekranlara haber ver
  }

  // 4. Ders Sil
  void deleteCourse(String courseId) {
    _courses.removeWhere((c) => c.id == courseId);
    _persistCourses();
    notifyListeners(); // 🔔 Ekranlara haber ver
  }
}
