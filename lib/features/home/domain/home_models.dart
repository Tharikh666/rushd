import 'package:flutter/material.dart';

enum PrayerStatus { completed, current, upcoming }

class PrayerItem {
  const PrayerItem({
    required this.id,
    required this.name,
    required this.time,
    required this.status,
    this.isOptional = false,
  });

  final String id;
  final String name;
  final TimeOfDay time;
  final PrayerStatus status;
  final bool isOptional;
}

class HomeSnapshot {
  const HomeSnapshot({
    required this.greetingName,
    required this.gregorianDate,
    required this.hijriDate,
    required this.locationLabel,
    required this.nextPrayer,
    required this.nextPrayerRemaining,
    required this.prayers,
    required this.quranProgress,
    required this.dhikrCount,
    required this.dailyGuidance,
  });

  final String greetingName;
  final String gregorianDate;
  final String hijriDate;
  final String locationLabel;
  final PrayerItem nextPrayer;
  final Duration nextPrayerRemaining;
  final List<PrayerItem> prayers;
  final QuranProgress quranProgress;
  final DhikrProgress dhikrCount;
  final DailyGuidance dailyGuidance;
}

class QuranProgress {
  const QuranProgress({
    required this.surahName,
    required this.verseLabel,
    required this.progress,
  });

  final String surahName;
  final String verseLabel;
  final double progress;
}

class DhikrProgress {
  const DhikrProgress({
    required this.completed,
    required this.target,
  });

  final int completed;
  final int target;
}

class DailyGuidance {
  const DailyGuidance({
    required this.title,
    required this.body,
    required this.source,
  });

  final String title;
  final String body;
  final String source;
}
