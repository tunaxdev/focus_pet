import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';

class PetRoomScreen extends StatelessWidget {
  const PetRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();

    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Odanın duvar rengi
      appBar: AppBar(
        title: const Text("My Pet 🏡"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          // Sağ üstte Coin göstergesi
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "${petProvider.coins}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- 1. PET ALANI (ORTA) ---
          Expanded(
            flex: 3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Konuşma Balonu (Duruma göre değişir)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      petProvider.hunger < 30
                          ? "I'm hungry! 🍖"
                          : (petProvider.happiness < 30
                                ? "Play with me! 🎾"
                                : "I love studying! 📚"),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Pet İkonu (İleride Resim Olacak)
                  // Animasyonlu bir efekt ekleyelim (Nefes alıyor gibi)
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 1.0, end: 1.05),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Icon(
                          Icons.pets, // Buraya petImage gelecek ileride
                          size: 180,
                          color: petProvider.hunger < 30
                              ? Colors.grey
                              : Colors.orange, // Açsa rengi solsun
                        ),
                      );
                    },
                    onEnd: () {}, // Loop yapılabilir ama şimdilik basit kalsın
                  ),
                ],
              ),
            ),
          ),

          // --- 2. KONTROL PANELİ (ALT) ---
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // İstatistikler (Hunger & Happiness)
                  _buildStatBar("Hunger 🍖", petProvider.hunger, Colors.orange),
                  const SizedBox(height: 15),
                  _buildStatBar(
                    "Happiness 💖",
                    petProvider.happiness,
                    Colors.pink,
                  ),

                  const Spacer(),

                  // Butonlar
                  Row(
                    children: [
                      // BESLE BUTONU
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (petProvider.coins >= 10) {
                              petProvider.feedPet();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Yummy! 😋 (-10 Coins)"),
                                  duration: Duration(milliseconds: 500),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Not enough coins! Go study! 📚",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.restaurant),
                          label: const Text("Feed (10c)"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade100,
                            foregroundColor: Colors.orange.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // OYNA BUTONU
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            petProvider.playWithPet();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("So fun! 🎉"),
                                duration: Duration(milliseconds: 500),
                              ),
                            );
                          },
                          icon: const Icon(Icons.sports_tennis),
                          label: const Text("Play"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade100,
                            foregroundColor: Colors.pink.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              "$value/100",
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / 100.0,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
