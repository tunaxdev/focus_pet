import 'package:flutter/material.dart';
import 'dart:async'; // Timer kullanmak için gerekli kütüphane

class FocusTimerCard extends StatefulWidget {
  const FocusTimerCard({super.key});

  @override
  State<FocusTimerCard> createState() => _FocusTimerCardState();
}

class _FocusTimerCardState extends State<FocusTimerCard> {
  // --- STATE VARIABLES ---

  // Total focus time in seconds (25 minutes * 60)
  static const int _initialTime = 25 * 60;

  // Current remaining seconds
  int _remainingSeconds = _initialTime;

  // Timer object to handle countdown
  Timer? _timer;

  // Is the timer currently running?
  bool _isRunning = false;

  // --- LOGIC METHODS ---

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    // Run this code every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // Time is up!
        _stopTimer();
        // TODO: Show "Session Complete" dialog later
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel(); // Kill the timer process
    setState(() {
      _isRunning = false;
    });
  }

  // Helper to format time (e.g., converts 65 seconds to "01:05")
  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    // padLeft(2, '0') adds a zero if the number is single digit (5 -> 05)
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Calculates progress for the circular indicator (1.0 = Full, 0.0 = Empty)
  double _getProgress() {
    return _remainingSeconds / _initialTime;
  }

  @override
  void dispose() {
    // Clean up timer when user leaves this screen to prevent memory leaks
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Focus Session",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 30),

          // Circular Timer Visualization
          Stack(
            alignment: Alignment.center,
            children: [
              // Background Circle (Grey)
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 15,
                  color: Colors.grey.shade100,
                ),
              ),
              // Progress Circle (Purple - Animated)
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _getProgress(), // Dynamic value
                  strokeWidth: 15,
                  strokeCap: StrokeCap.round,
                  color: const Color(0xFF6C63FF),
                  backgroundColor: Colors.transparent,
                ),
              ),
              // Time Text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(_remainingSeconds), // Dynamic text
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const Text(
                    "minutes",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Start/Pause Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _toggleTimer, // Connect logic
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning
                    ? Colors.orangeAccent
                    : const Color(0xFF6C63FF), // Change color
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              // Change icon and text based on state
              icon: Icon(
                _isRunning ? Icons.pause : Icons.play_arrow_rounded,
                size: 28,
              ),
              label: Text(
                _isRunning ? "Pause Focus" : "Start Focus",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
