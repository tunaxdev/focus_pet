import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // Varsayılan Değerler
  String _username = "User";
  bool _isHapticEnabled = true;
  bool _isDarkMode = false;
  String _language = "en";

  // Getterlar
  String get username => _username;
  bool get isHapticEnabled => _isHapticEnabled;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;

  // Başlatıcı
  SettingsProvider() {
    _loadPreferences();
  }

  // Verileri Yükle
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? "User";
    _isHapticEnabled = prefs.getBool('isHapticEnabled') ?? true;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _language = prefs.getString('language') ?? "en";
    notifyListeners();
  }

  // İsim Değiştir
  Future<void> setUsername(String name) async {
    _username = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
    notifyListeners();
  }

  // Titreşim Aç/Kapa
  Future<void> toggleHaptic(bool value) async {
    _isHapticEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHapticEnabled', value);
    notifyListeners();
  }

  // Karanlık Mod Aç/Kapa
  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  // Dil Değiştir
  Future<void> setLanguage(String langCode) async {
    _language = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    notifyListeners();
  }
}
