import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetProvider with ChangeNotifier {
  // --- 1. TEMEL DEĞİŞKENLER ---
  int _coins = 100;
  int _xp = 0;
  int _level = 1;
  int _streak = 0;

  // --- 2. PET DURUMU (Pet Room İçin) ---
  int _hunger = 50; // 0 ile 100 arası
  int _happiness = 50; // 0 ile 100 arası

  // --- 3. FOCUS MODU HEDEFLERİ ---
  int _dailyGoal = 60;
  int _dailyProgress = 0;
  int _monthlyProgress = 0;
  String _lastFocusDate = "";

  // --- GETTERLAR (Dışarıdan Okuma) ---
  int get coins => _coins;
  int get currentXp => _xp; // Dashboard bazen currentXp diye arar
  int get xp => _xp; // Bazen de xp diye arar
  int get level => _level;
  int get streak => _streak;

  // Pet Room Getterları
  int get hunger => _hunger;
  int get happiness => _happiness;

  // XP Bar Hesabı
  int get targetXp => 100;
  double get xpProgress {
    double progress = _xp / 100.0;
    return progress > 1.0 ? 1.0 : progress;
  }

  // Focus Modu Getterları
  int get dailyGoal => _dailyGoal;
  int get dailyProgress => _dailyProgress;
  int get monthlyProgress => _monthlyProgress;

  double get dailyGoalProgress {
    if (_dailyGoal == 0) return 0;
    double progress = _dailyProgress / _dailyGoal;
    return progress > 1.0 ? 1.0 : progress;
  }

  // Pet Görseli Getterı (Seviyeye göre)
  String get petImage {
    // Şimdilik sadece asset yollarını döndürüyoruz
    // İleride buraya gerçek resimler koyacağız
    if (_level < 5) return 'assets/images/pet_baby.png';
    return 'assets/images/pet_adult.png';
  }

  // --- BAŞLATMA ---
  PetProvider() {
    loadPetData();
  }

  // --- VERİLERİ YÜKLEME ---
  Future<void> loadPetData() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 100;
    _xp = prefs.getInt('xp') ?? 0;
    _level = prefs.getInt('level') ?? 1;
    _streak = prefs.getInt('streak') ?? 0;

    _hunger = prefs.getInt('hunger') ?? 50;
    _happiness = prefs.getInt('happiness') ?? 50;

    _dailyGoal = prefs.getInt('dailyGoal') ?? 60;
    _dailyProgress = prefs.getInt('dailyProgress') ?? 0;
    _monthlyProgress = prefs.getInt('monthlyProgress') ?? 0;
    _lastFocusDate = prefs.getString('lastFocusDate') ?? "";

    _checkNewDay();
    notifyListeners();
  }

  // Yeni gün kontrolü
  void _checkNewDay() {
    String today = DateTime.now().toIso8601String().split('T')[0];
    if (_lastFocusDate != today) {
      _dailyProgress = 0;
      // Yeni gün: Pet biraz acıkır ve mutsuzlaşır
      _hunger = (_hunger - 20).clamp(0, 100);
      _happiness = (_happiness - 10).clamp(0, 100);

      _lastFocusDate = today;
      _saveData();
    }
  }

  // Verileri Kaydetme
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('coins', _coins);
    prefs.setInt('xp', _xp);
    prefs.setInt('level', _level);
    prefs.setInt('streak', _streak);
    prefs.setInt('hunger', _hunger);
    prefs.setInt('happiness', _happiness);
    prefs.setInt('dailyGoal', _dailyGoal);
    prefs.setInt('dailyProgress', _dailyProgress);
    prefs.setInt('monthlyProgress', _monthlyProgress);
    prefs.setString('lastFocusDate', _lastFocusDate);
  }

  // --- FONKSİYONLAR ---

  // 1. Pet Besleme (Pet Room)
  Future<void> feedPet() async {
    const int foodCost = 10;
    if (_coins >= foodCost && _hunger < 100) {
      _coins -= foodCost;
      _hunger = (_hunger + 20).clamp(0, 100); // Açlığı azalt (doyur)
      _happiness = (_happiness + 5).clamp(0, 100);
      await _saveData();
      notifyListeners();
    }
  }

  // 2. Pet ile Oynama (Pet Room)
  Future<void> playWithPet() async {
    if (_happiness < 100) {
      _happiness = (_happiness + 15).clamp(0, 100);
      _hunger = (_hunger - 5).clamp(0, 100); // Oynamak acıktırır
      await _saveData();
      notifyListeners();
    }
  }

  // 3. Günlük Hedef Güncelleme (Focus Modu)
  Future<void> updateDailyGoal(int newGoal) async {
    _dailyGoal = newGoal;
    notifyListeners();
    await _saveData();
  }

  // 4. Focus Ödül Sistemi (Focus Modu)
  Map<String, dynamic> rewardFocus(int minutes) {
    int earnedXp = minutes * 5;
    int bonusCoins = (minutes / 10).floor() * 2;

    _xp += earnedXp;
    _coins += bonusCoins;
    _dailyProgress += minutes;

    // Focus yapmak peti de mutlu eder!
    _happiness = (_happiness + 10).clamp(0, 100);

    bool leveledUp = false;
    if (_xp >= 100) {
      _level += (_xp / 100).floor();
      _xp = _xp % 100;
      leveledUp = true;
    }

    String milestoneMsg = "";
    if (_dailyProgress >= _dailyGoal &&
        (_dailyProgress - minutes) < _dailyGoal) {
      milestoneMsg = "Daily Goal Reached! 🎯 (+50 Bonus Coins)";
      _coins += 50;
      _streak++;
      _monthlyProgress++;
      if (_monthlyProgress > 30) _monthlyProgress = 1;
    }

    _saveData();
    notifyListeners();

    return {
      'leveledUp': leveledUp,
      'earnedXp': earnedXp,
      'bonusCoins': bonusCoins,
      'milestoneMsg': milestoneMsg,
    };
  }
}
