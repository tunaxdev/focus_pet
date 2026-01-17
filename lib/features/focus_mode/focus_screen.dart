import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/pet_model.dart'; // Modelimizi import ettik

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  // --- STATE DEĞİŞKENLERİ ---

  // Başlangıçta Pet'imiz "Idle" (Boşta) modunda
  PetModel _myPet = PetModel(name: "Sparky", state: PetState.idle);

  final List<int> _presets = [15, 25, 45, 60];
  int _selectedDuration = 25;

  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  // --- MANTIK FONKSİYONLARI ---

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _selectedDuration * 60;
      _isRunning = false;
      _myPet = _myPet.copyWith(
        state: PetState.idle,
      ); // Resetlenince pet normale dönsün
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      // Durdurma
      _timer?.cancel();
      setState(() {
        _isRunning = false;
        _myPet = _myPet.copyWith(state: PetState.idle); // Durunca bekleme modu
      });
    } else {
      // Başlatma
      setState(() {
        _isRunning = true;
        _myPet = _myPet.copyWith(
          state: PetState.focused,
        ); // Başlayınca odaklanma modu
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          // Süre Bitti
          _timer?.cancel();
          setState(() {
            _isRunning = false;
            _myPet = _myPet.copyWith(
              state: PetState.happy,
            ); // Bittiğinde kutlama modu!
          });
          debugPrint("Süre bitti! Pet Mutlu!");
        }
      });
    }
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 👇 İŞTE SORDUĞUN FONKSİYONU BURAYA KOYUYORUZ (Build'den önce) 👇
  // Bu fonksiyon Pet'in durumuna (State) bakıp doğru ikonu seçer
  Icon _getPetIcon(PetState state) {
    switch (state) {
      case PetState.focused:
        return const Icon(
          Icons.menu_book,
          size: 100,
          color: Color(0xFF6C63FF),
        ); // Ders çalışıyor
      case PetState.happy:
        return const Icon(
          Icons.celebration,
          size: 100,
          color: Colors.orange,
        ); // Kutlama!
      case PetState.idle:
      default:
        return const Icon(
          Icons.pets,
          size: 100,
          color: Colors.grey,
        ); // Bekliyor
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- ARAYÜZ (BUILD) ---
  @override
  Widget build(BuildContext context) {
    double progress = _remainingSeconds / (_selectedDuration * 60);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Focus Mode",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTimer,
            tooltip: "Reset Timer",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- 1. PET ALANI ---
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 👇 ESKİ ICON KODUNU SİLDİK, YERİNE FONKSİYONU ÇAĞIRDIK 👇
                    _getPetIcon(_myPet.state),

                    const SizedBox(height: 16),
                    Text(
                      _isRunning ? "Working with you..." : "Ready to focus?",
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. SAYAÇ GÖSTERGESİ ---
            Expanded(
              flex: 4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 20,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.grey.shade100,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Roboto",
                    ),
                  ),
                ],
              ),
            ),

            // --- 3. SÜRE SEÇİM ---
            if (!_isRunning)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _presets.map((time) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text("$time min"),
                        selected: _selectedDuration == time,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedDuration = time;
                            _resetTimer();
                          });
                        },
                        selectedColor: const Color(
                          0xFF6C63FF,
                        ).withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: _selectedDuration == time
                              ? const Color(0xFF6C63FF)
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 30),

            // --- 4. BUTON ---
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _toggleTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning
                      ? Colors.orangeAccent
                      : const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                label: Text(
                  _isRunning ? "Pause Focus" : "Start Focus",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
