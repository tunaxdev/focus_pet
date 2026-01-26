import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ayarları dinle (Değişiklik olunca ekranı yenile)
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings ⚙️"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- KULLANICI PROFİLİ ---
          const Text(
            "PROFILE",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your Name",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        TextField(
                          // Mevcut ismi göster
                          controller: TextEditingController(
                            text: settings.username,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter your name",
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          // Enter'a basınca kaydet
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              settings.setUsername(value);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Hello, $value! 👋")),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --- PREFERENCES (TERCİHLER) ---
          const Text(
            "PREFERENCES",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // 1. Haptic Feedback (Titreşim)
          _buildSwitchTile(
            context,
            title: "Haptic Feedback",
            subtitle: "Vibrate on buttons & timer completion",
            icon: Icons.vibration,
            value: settings.isHapticEnabled,
            onChanged: (val) => settings.toggleHaptic(val),
          ),

          // 2. Dark Mode (Karanlık Mod)
          _buildSwitchTile(
            context,
            title: "Dark Mode",
            subtitle: "Easier on the eyes at night",
            icon: Icons.dark_mode,
            value: settings.isDarkMode,
            onChanged: (val) => settings.toggleTheme(val),
          ),

          // 3. Dil Seçeneği (Basit Toggle)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.language, color: Colors.orange),
              ),
              title: const Text("Language"),
              subtitle: Text(settings.language == 'en' ? "English" : "Türkçe"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Basit dil değiştirme (İleride geliştirebiliriz)
                if (settings.language == 'en') {
                  settings.setLanguage('tr');
                } else {
                  settings.setLanguage('en');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Ayar kutucuklarını oluşturan yardımcı widget
  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeColor: Colors.purple,
        onChanged: onChanged,
      ),
    );
  }
}
