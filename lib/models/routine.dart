import 'dart:convert';

class Routine {
  final String id;
  final String title;
  final String time; // e.g. "07:00" (24h) or "07:00 AM"
  final bool isRecurring;
  final List<int> daysOfWeek; // 1 = Mon, 7 = Sun
  final String routineType; // 'morning', 'afternoon', 'evening', 'anytime'
  final String priority; // 'high', 'medium', 'low'
  final bool isCompleted;
  final int streak;
  final String? lastCompletedDate; // 'YYYY-MM-DD'
  final String createdAt;

  Routine({
    required this.id,
    required this.title,
    required this.time,
    this.isRecurring = true,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.routineType = 'morning',
    this.priority = 'medium',
    this.isCompleted = false,
    this.streak = 0,
    this.lastCompletedDate,
    required this.createdAt,
  });

  Routine copyWith({
    String? id,
    String? title,
    String? time,
    bool? isRecurring,
    List<int>? daysOfWeek,
    String? routineType,
    String? priority,
    bool? isCompleted,
    int? streak,
    String? lastCompletedDate,
    String? createdAt,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isRecurring: isRecurring ?? this.isRecurring,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      routineType: routineType ?? this.routineType,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      streak: streak ?? this.streak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'is_recurring': isRecurring ? 1 : 0,
      'days_of_week': jsonEncode(daysOfWeek),
      'routine_type': routineType,
      'priority': priority,
      'is_completed': isCompleted ? 1 : 0,
      'streak': streak,
      'last_completed_date': lastCompletedDate,
      'created_at': createdAt,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    List<int> parsedDays = [1, 2, 3, 4, 5, 6, 7];
    if (map['days_of_week'] != null) {
      try {
        final decoded = jsonDecode(map['days_of_week'] as String);
        if (decoded is List) {
          parsedDays = decoded.map((e) => int.parse(e.toString())).toList();
        }
      } catch (_) {}
    }

    return Routine(
      id: map['id'] as String,
      title: map['title'] as String,
      time: map['time'] as String? ?? '08:00',
      isRecurring: (map['is_recurring'] as int? ?? 1) == 1,
      daysOfWeek: parsedDays,
      routineType: map['routine_type'] as String? ?? 'morning',
      priority: map['priority'] as String? ?? 'medium',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      streak: map['streak'] as int? ?? 0,
      lastCompletedDate: map['last_completed_date'] as String?,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
