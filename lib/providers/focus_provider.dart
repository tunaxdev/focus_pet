import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FocusProvider with ChangeNotifier {
  // Varsayılan süreler
  int _targetMinutes = 25; // Hedeflenen dakika
  int _remainingSeconds = 25 * 60;

  Timer? _timer;
  bool _isRunning = false;
  bool _isSessionCompleted = false; // Seans başarıyla bitti mi?

  // Getterlar
  int get remainingSeconds => _remainingSeconds;
  int get targetMinutes => _targetMinutes; // UI'da göstermek için
  bool get isRunning => _isRunning;
  bool get isSessionCompleted => _isSessionCompleted;

  double get progress => _remainingSeconds / (_targetMinutes * 60);

  String get timerString {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // 1. Süreyi Ayarla (Sadece sayaç çalışmıyorken)
  void setDuration(int minutes) {
    if (!_isRunning) {
      _targetMinutes = minutes;
      _remainingSeconds = minutes * 60;
      notifyListeners();
    }
  }

  // 2. Başlat / Duraklat
  void toggleTimer() {
    if (_isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    WakelockPlus.enable();
    _isRunning = true;
    _isSessionCompleted = false;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _completeTimer();
      }
    });
  }

  void pauseTimer() {
    WakelockPlus.disable();
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void _completeTimer() {
    _timer?.cancel();
    _isRunning = false;
    _remainingSeconds = _targetMinutes * 60; // Başa sar ama hedef süreyi koru
    _isSessionCompleted = true; // UI'da tebrik mesajı için

    // Not: Pet ödül mantığını UI tarafında çağıracağız
    notifyListeners();
  }

  // Sayacı Sıfırla
  void resetTimer() {
    pauseTimer();
    _remainingSeconds = _targetMinutes * 60;
    _isSessionCompleted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
