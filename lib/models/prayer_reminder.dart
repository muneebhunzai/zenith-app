class PrayerReminder {
  final String id;
  final String name;
  final String scheduledTime; // "HH:mm" in 24h format e.g. "05:15"
  final bool isEnabled;
  final bool isCompletedToday;
  final String? lastCompletedDate;

  PrayerReminder({
    required this.id,
    required this.name,
    required this.scheduledTime,
    this.isEnabled = true,
    this.isCompletedToday = false,
    this.lastCompletedDate,
  });

  PrayerReminder copyWith({
    String? id,
    String? name,
    String? scheduledTime,
    bool? isEnabled,
    bool? isCompletedToday,
    String? lastCompletedDate,
  }) {
    return PrayerReminder(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isEnabled: isEnabled ?? this.isEnabled,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scheduled_time': scheduledTime,
      'is_enabled': isEnabled ? 1 : 0,
      'is_completed_today': isCompletedToday ? 1 : 0,
      'last_completed_date': lastCompletedDate,
    };
  }

  factory PrayerReminder.fromMap(Map<String, dynamic> map) {
    return PrayerReminder(
      id: map['id'] as String,
      name: map['name'] as String,
      scheduledTime: map['scheduled_time'] as String? ?? '06:00',
      isEnabled: (map['is_enabled'] as int? ?? 1) == 1,
      isCompletedToday: (map['is_completed_today'] as int? ?? 0) == 1,
      lastCompletedDate: map['last_completed_date'] as String?,
    );
  }
}
