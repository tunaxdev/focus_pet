import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// Kendi dosyalarımız
import '../../services/notification_service.dart';
import '../../providers/focus_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/settings_provider.dart';
import '../dashboard/widgets/streak_badge.dart';
import '../dashboard/widgets/settings_icon.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentSound;
  bool _isAmbiencePaused = false;
  DateTime? _backgroundExitTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final focusProvider = context.read<FocusProvider>();
    if (!focusProvider.isRunning) return;

    if (state == AppLifecycleState.paused) {
      _backgroundExitTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundExitTime != null) {
        final timePassed = DateTime.now().difference(_backgroundExitTime!);
        if (timePassed.inSeconds > 10) {
          focusProvider.pauseTimer();
          if (_currentSound != null && !_isAmbiencePaused) {
            _audioPlayer.pause();
            setState(() => _isAmbiencePaused = true);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You were gone too long! Focus paused. 🥺"),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 4),
            ),
          );
        }
        _backgroundExitTime = null;
      }
    }
  }

  Future<void> _toggleSound(String soundFile) async {
    if (_currentSound != soundFile) {
      await _audioPlayer.setVolume(1.0);
      try {
        await _audioPlayer.play(AssetSource('sounds/$soundFile'));
      } catch (_) {
        // Sound files are not bundled in the repository (see README).
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sound file not found: assets/sounds/$soundFile")),
        );
        return;
      }
      setState(() {
        _currentSound = soundFile;
        _isAmbiencePaused = false;
      });
    }
  }

  Future<void> _togglePlayPauseAmbience() async {
    if (_currentSound == null) return;
    if (_isAmbiencePaused) {
      await _audioPlayer.resume();
    } else {
      await _audioPlayer.pause();
    }
    setState(() => _isAmbiencePaused = !_isAmbiencePaused);
  }

  Future<void> _closeAmbience() async {
    await _audioPlayer.stop();
    setState(() {
      _currentSound = null;
      _isAmbiencePaused = false;
    });
  }

  String _getSoundName(String file) {
    switch (file) {
      case "gentle-rain.mp3":
        return "Rain 🌧️";
      case "fire-sound.mp3":
        return "Fire 🔥";
      case "cafe-noise.mp3":
        return "Cafe ☕";
      case "white-noise.mp3":
        return "White Noise 🌊";
      default:
        return "Ambience 🎵";
    }
  }

  void _openEcoMode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setEcoState) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    blurRadius: 60,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.pets,
                                size: 100,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Consumer<FocusProvider>(
                              builder: (context, focusProvider, child) {
                                return Text(
                                  focusProvider.timerString,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 80,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w100,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Battery Saver On",
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_currentSound != null)
                        Positioned(
                          top: 60,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      await _togglePlayPauseAmbience();
                                      setEcoState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isAmbiencePaused
                                                ? Icons.play_arrow_rounded
                                                : Icons.pause_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isAmbiencePaused
                                                ? "Paused"
                                                : _getSoundName(_currentSound!),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 20,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await _closeAmbience();
                                      setEcoState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 50,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Text(
                              "Don't lock the screen 🔒",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Tap anywhere to wake up 👆",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.15),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusProvider = context.watch<FocusProvider>();
    final petProvider = context.watch<PetProvider>();
    final settings = context.watch<SettingsProvider>();

    if (focusProvider.isSessionCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentSound != null) _closeAmbience();
        NotificationService().showInstantNotification(
          title: "Focus Session Complete! 🎉",
          body: "Great job! Come back to claim your reward & XP!",
        );
        final result = context.read<PetProvider>().rewardFocus(
          focusProvider.targetMinutes,
        );
        _showCompletionDialog(context, result);
        focusProvider.resetTimer();
      });
    }

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (OPTİMİZE EDİLDİ) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              child: SizedBox(
                height: 56, // Standart AppBar yüksekliği
                child: Row(
                  children: [
                    // Sol: Müzik Butonu
                    IconButton(
                      icon: Icon(
                        _currentSound == null
                            ? Icons.music_note_outlined
                            : Icons.graphic_eq,
                        color: _currentSound == null
                            ? Colors.grey
                            : primaryColor,
                      ),
                      onPressed: () => _showAmbienceSheet(context),
                    ),

                    // Orta: Başlık
                    const Expanded(
                      child: Text(
                        "Focus Mode",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Sağ: Streak ve Ayarlar
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (focusProvider.isRunning)
                          IconButton(
                            icon: const Icon(Icons.bolt, color: Colors.green),
                            onPressed: () {
                              if (settings.isHapticEnabled)
                                HapticFeedback.lightImpact();
                              _openEcoMode(context);
                            },
                          )
                        else
                          const StreakBadge(),

                        const SizedBox(width: 4), // Dashboard ile aynı boşluk
                        const SettingsIcon(),
                        const SizedBox(width: 4), // Sağ kenar dengesi
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    if (_currentSound != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: _isAmbiencePaused
                              ? Colors.grey.shade200
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _isAmbiencePaused
                                ? Colors.grey.shade400
                                : Colors.blue.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: _togglePlayPauseAmbience,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(30),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  10,
                                  8,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isAmbiencePaused
                                          ? Icons.play_arrow_rounded
                                          : Icons.pause_rounded,
                                      size: 20,
                                      color: _isAmbiencePaused
                                          ? Colors.grey
                                          : Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isAmbiencePaused
                                          ? "Paused"
                                          : _getSoundName(_currentSound!),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _isAmbiencePaused
                                            ? Colors.grey
                                            : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: _isAmbiencePaused
                                  ? Colors.grey.shade300
                                  : Colors.blue.shade200,
                            ),
                            InkWell(
                              onTap: _closeAmbience,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(30),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  8,
                                  16,
                                  8,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: _isAmbiencePaused
                                      ? Colors.grey
                                      : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      focusProvider.isRunning
                          ? "Studying with Pet... 📚"
                          : "Ready to Focus?",
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: focusProvider.progress,
                            strokeWidth: 20,
                            backgroundColor: Colors.grey.shade200,
                            color: primaryColor,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: focusProvider.isRunning
                                  ? Icon(
                                      Icons.menu_book,
                                      key: const ValueKey(1),
                                      size: 65,
                                      color: primaryColor,
                                    )
                                  : Icon(
                                      Icons.pets,
                                      key: const ValueKey(2),
                                      size: 65,
                                      color: Colors.grey.shade400,
                                    ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              focusProvider.timerString,
                              style: const TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (!focusProvider.isRunning) ...[
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          const Text(
                            "Session Duration",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Slider(
                              value: focusProvider.targetMinutes.toDouble(),
                              min: 5,
                              max: 120,
                              divisions: 23,
                              label: "${focusProvider.targetMinutes} min",
                              activeColor: primaryColor,
                              onChanged: (val) =>
                                  focusProvider.setDuration(val.toInt()),
                            ),
                          ),
                          Text(
                            "+ ${focusProvider.targetMinutes * 10} XP Potential ✨",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- ALT PANEL ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _showSetGoalDialog(context, petProvider),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Daily Goal 🎯",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                            Text(
                              "${petProvider.dailyProgress}/${petProvider.dailyGoal} min",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: petProvider.dailyGoalProgress,
                            backgroundColor: Colors.grey.shade200,
                            color:
                                petProvider.dailyProgress >=
                                    petProvider.dailyGoal
                                ? Colors.green
                                : Colors.orangeAccent,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showQuestsDialog(context, petProvider),
                          icon: const Icon(Icons.assignment_outlined, size: 18),
                          label: const Text("Quests"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            side: BorderSide(color: Colors.indigo.shade100),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showRewardsDialog(context, petProvider),
                          icon: const Icon(
                            Icons.emoji_events_outlined,
                            size: 18,
                          ),
                          label: const Text("Rewards"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber.shade900,
                            side: BorderSide(color: Colors.amber.shade200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (focusProvider.isRunning ||
                          focusProvider.remainingSeconds !=
                              focusProvider.targetMinutes * 60)
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: FloatingActionButton(
                              heroTag: "reset",
                              onPressed: () =>
                                  _confirmGiveUp(context, focusProvider),
                              backgroundColor: Colors.grey.shade200,
                              elevation: 0,
                              child: const Icon(
                                Icons.stop,
                                color: Colors.redAccent,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: FloatingActionButton(
                          heroTag: "start_stop",
                          onPressed: () {
                            if (settings.isHapticEnabled)
                              HapticFeedback.lightImpact();
                            focusProvider.toggleTimer();
                          },
                          backgroundColor: focusProvider.isRunning
                              ? Colors.orangeAccent
                              : primaryColor,
                          elevation: 4,
                          child: Icon(
                            focusProvider.isRunning
                                ? Icons.pause
                                : Icons.play_arrow_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAmbienceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Ambient Sounds 🎧",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSoundOption("Rain", "gentle-rain.mp3", Icons.water_drop),
            _buildSoundOption(
              "Fire",
              "fire-sound.mp3",
              Icons.local_fire_department,
            ),
            _buildSoundOption("Cafe", "cafe-noise.mp3", Icons.coffee),
            _buildSoundOption("White Noise", "white-noise.mp3", Icons.waves),
            if (_currentSound != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  _closeAmbience();
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.stop_circle_outlined, color: Colors.red),
                label: const Text(
                  "Stop Sound",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSoundOption(String name, String file, IconData icon) {
    bool isSelected = _currentSound == file;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      title: Text(
        name,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.volume_up, color: Colors.blue)
          : null,
      onTap: () {
        _toggleSound(file);
        Navigator.pop(context);
      },
    );
  }

  void _confirmGiveUp(BuildContext context, FocusProvider focusProvider) {
    if (focusProvider.isRunning) focusProvider.pauseTimer();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Give Up? 🥺"),
        content: const Text(
          "You will lose your current progress.\nAre you sure you want to stop?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              focusProvider.startTimer();
            },
            child: const Text("No, Keep Focusing"),
          ),
          ElevatedButton(
            onPressed: () {
              _closeAmbience();
              focusProvider.resetTimer();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yes, Stop"),
          ),
        ],
      ),
    );
  }

  void _showSetGoalDialog(BuildContext context, PetProvider petProvider) {
    double tempGoal = petProvider.dailyGoal.toDouble();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Set Daily Goal 🎯"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Challenge yourself! (30 - 120 min)"),
              const SizedBox(height: 20),
              Text(
                "${tempGoal.toInt()} min",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Slider(
                value: tempGoal,
                min: 30,
                max: 120,
                divisions: 6,
                label: "${tempGoal.toInt()} min",
                onChanged: (val) => setState(() => tempGoal = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                petProvider.updateDailyGoal(tempGoal.toInt());
                Navigator.pop(ctx);
              },
              child: const Text("Save Goal"),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestsDialog(BuildContext context, PetProvider petProvider) {
    bool goalReached = petProvider.dailyProgress >= petProvider.dailyGoal;
    bool streakActive = petProvider.streak > 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.assignment_turned_in, color: Colors.indigo),
            SizedBox(width: 8),
            Text("Daily Quests"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuestCard(
              title: "Reach Daily Goal",
              subtitle:
                  "${petProvider.dailyProgress} / ${petProvider.dailyGoal} min",
              isCompleted: goalReached,
              reward: "50 Coins",
              color: Colors.blue.shade50,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 10),
            _buildQuestCard(
              title: "Keep the Streak",
              subtitle: "Current: ${petProvider.streak} Days",
              isCompleted: streakActive,
              reward: "Streak +1",
              color: Colors.orange.shade50,
              iconColor: Colors.orange,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required String reward,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? iconColor.withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(
              isCompleted
                  ? Icons.check
                  : (title.contains("Streak")
                        ? Icons.local_fire_department
                        : Icons.flag),
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (!isCompleted)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Reward",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
                Text(
                  reward,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            )
          else
            const Icon(Icons.done_all, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  void _showRewardsDialog(BuildContext context, PetProvider petProvider) {
    int currentCycleDay = (petProvider.streak % 7);
    if (currentCycleDay == 0 && petProvider.streak > 0) currentCycleDay = 7;
    int monthlyProgress = petProvider.monthlyProgress;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        title: const Center(
          child: Text(
            "Streak Rewards 🏆",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Weekly Cycle",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDayBox(
                  day: 1,
                  currentDay: currentCycleDay,
                  reward: "50c",
                ),
                _buildDayBox(
                  day: 2,
                  currentDay: currentCycleDay,
                  reward: "50c",
                ),
                _buildDayBox(
                  day: 3,
                  currentDay: currentCycleDay,
                  reward: "50c",
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDayBox(
                  day: 4,
                  currentDay: currentCycleDay,
                  reward: "50c",
                ),
                _buildDayBox(
                  day: 5,
                  currentDay: currentCycleDay,
                  reward: "50c",
                ),
                _buildDayBox(
                  day: 6,
                  currentDay: currentCycleDay,
                  reward: "50c",
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildBigPrizeBox(day: 7, currentDay: currentCycleDay),
            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Road to Legendary Box 🗝️",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$monthlyProgress / 30 Days",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Icon(Icons.emoji_events, color: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: monthlyProgress / 30.0,
                      minHeight: 12,
                      backgroundColor: Colors.deepPurple.shade100,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Huge Reward at Day 30!",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Keep Going!"),
          ),
        ],
      ),
    );
  }

  Widget _buildDayBox({
    required int day,
    required int currentDay,
    required String reward,
  }) {
    bool isCompleted = day < currentDay;
    bool isToday = day == currentDay;
    bool isLocked = day > currentDay;
    return Container(
      width: 70,
      height: 80,
      decoration: BoxDecoration(
        color: isToday
            ? Colors.orange.shade100
            : (isCompleted ? Colors.green.shade50 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
        border: isToday ? Border.all(color: Colors.orange, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Day $day",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.grey : Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Icon(
            isCompleted
                ? Icons.check_circle
                : (isToday ? Icons.local_fire_department : Icons.lock),
            size: 24,
            color: isCompleted
                ? Colors.green
                : (isToday ? Colors.orange : Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            isCompleted ? "Claimed" : reward,
            style: TextStyle(
              fontSize: 10,
              color: isLocked ? Colors.grey : Colors.brown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigPrizeBox({required int day, required int currentDay}) {
    bool isCompleted = day < currentDay;
    bool isToday = day == currentDay;
    bool isLocked = day > currentDay;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: isLocked
            ? LinearGradient(
                colors: [Colors.grey.shade100, Colors.grey.shade200],
              )
            : const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]),
        border: isLocked ? Border.all(color: Colors.grey.shade300) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLocked ? Colors.white : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_giftcard,
              color: isLocked ? Colors.grey.shade400 : Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Day 7: Weekly Gift",
                style: TextStyle(
                  color: isLocked ? Colors.grey.shade700 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                isToday
                    ? "Tap to Claim!"
                    : (isCompleted ? "Claimed" : "+200 Coins"),
                style: TextStyle(
                  color: isLocked ? Colors.grey.shade500 : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (isToday)
            const Icon(Icons.lock_open, color: Colors.white)
          else if (isLocked)
            Icon(Icons.lock, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  void _showCompletionDialog(
    BuildContext context,
    Map<String, dynamic> result,
  ) {
    final bool leveledUp = result['leveledUp'];
    final int earnedXp = result['earnedXp'];
    final int bonusCoins = result['bonusCoins'];
    final String milestoneMsg = result['milestoneMsg'];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          leveledUp ? "LEVEL UP! 🚀" : "Session Complete! 🎉",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              leveledUp ? Icons.rocket_launch : Icons.check_circle,
              color: leveledUp ? Colors.purple : Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              "+ $earnedXp XP",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            if (bonusCoins > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "+ $bonusCoins Coins Bonus! 💰",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (milestoneMsg.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  milestoneMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Text(
              "Your pet is studying with you! 📚",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Awesome!", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
