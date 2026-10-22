
class YaseenAyah {
  final int ayahNumber;
  final String arabic;
  final String englishTransliteration;
  final String malayalamTransliteration;
  final String englishTranslation;
  final String malayalamTranslation;

  const YaseenAyah({
    required this.ayahNumber,
    required this.arabic,
    required this.englishTransliteration,
    required this.malayalamTransliteration,
    required this.englishTranslation,
    required this.malayalamTranslation,
  });

  factory YaseenAyah.fromJson(Map<String, dynamic> json) {
    return YaseenAyah(
      ayahNumber: json['ayah_number'] as int,
      arabic: json['arabic'] as String,
      englishTransliteration:
      json['english_transliteration'] as String,
      malayalamTransliteration:
      json['malayalam_transliteration'] as String,
      englishTranslation: json['english_translation'] as String,
      malayalamTranslation: json['malayalam_translation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_number': ayahNumber,
      'arabic': arabic,
      'english_transliteration': englishTransliteration,
      'malayalam_transliteration': malayalamTransliteration,
      'english_translation': englishTranslation,
      'malayalam_translation': malayalamTranslation,
    };
  }
}
