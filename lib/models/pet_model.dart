// Pet'in içinde bulunabileceği tüm ruh halleri
enum PetState {
  idle, // Boşta duruyor (Göz kırpıyor, bekliyor)
  sleeping, // Uygulama kapalıyken veya gece
  focused, // Sayaç çalışırken (Gözlük takmış, kitap okuyor vb.)
  happy, // Sayaç başarıyla bittiğinde (Zıplıyor, konfeti)
  tired, // Çok uzun süre ara vermeden çalışırsan (Opsiyonel)
}

class PetModel {
  final String name;
  final int level;
  final int currentXp;
  final int requiredXpForNextLevel;
  final PetState state; // Şu anki durumu

  // Constructor (Kurucu)
  PetModel({
    required this.name,
    this.level = 1,
    this.currentXp = 0,
    this.requiredXpForNextLevel = 100,
    this.state = PetState.idle,
  });

  // Durumu değiştirmek için kopya oluşturan metod (Immutable yapı)
  PetModel copyWith({
    String? name,
    int? level,
    int? currentXp,
    int? requiredXpForNextLevel,
    PetState? state,
  }) {
    return PetModel(
      name: name ?? this.name,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      requiredXpForNextLevel:
          requiredXpForNextLevel ?? this.requiredXpForNextLevel,
      state: state ?? this.state,
    );
  }
}
