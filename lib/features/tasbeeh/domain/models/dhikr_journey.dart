class DhikrJourney {
  const DhikrJourney({
    required this.id,
    required this.name,
    required this.currentCount,
    required this.targetCount,
    required this.createdAt,
    this.duaId,
  });

  final String id;
  final String name;
  final int currentCount;
  final int targetCount;
  final DateTime createdAt;

  /// ID of the source Dua, if this journey was created from a Dua.
  /// Null for journeys created directly from Tasbeeh.
  final String? duaId;

  double get progress {
    if (targetCount <= 0) return 0;
    return (currentCount / targetCount).clamp(0.0, 1.0);
  }

  int get remainingCount {
    return (targetCount - currentCount).clamp(0, targetCount);
  }

  bool get isCompleted => currentCount >= targetCount;

  DhikrJourney copyWith({
    String? name,
    int? currentCount,
    int? targetCount,
    String? duaId,
    bool clearDuaId = false,
  }) {
    return DhikrJourney(
      id: id,
      name: name ?? this.name,
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount ?? this.targetCount,
      createdAt: createdAt,
      duaId: clearDuaId ? null : (duaId ?? this.duaId),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentCount': currentCount,
      'targetCount': targetCount,
      'createdAt': createdAt.toIso8601String(),
      'duaId': duaId,
    };
  }

  factory DhikrJourney.fromJson(Map<String, dynamic> json) {
    return DhikrJourney(
      id: json['id'] as String,
      name: json['name'] as String,
      currentCount: (json['currentCount'] as num).toInt(),
      targetCount: (json['targetCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      // Older saved journeys won't have this key.
      duaId: json['duaId'] as String?,
    );
  }
}
