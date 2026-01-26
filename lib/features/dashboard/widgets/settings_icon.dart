import 'package:flutter/material.dart';
// Doğru yol: Bir üst klasöre çık (dashboard), bir üst klasöre daha çık (features), sonra settings'e gir
import '../../settings/settings_screen.dart';

class SettingsIcon extends StatelessWidget {
  const SettingsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined, color: Colors.grey),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      },
    );
  }
}
