import 'dart:convert';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String mood; // 'Great', 'Good', 'Neutral', 'Low', 'Stressed'
  final List<String> tags;
  final String date; // 'YYYY-MM-DD'
  final bool isPinned;
  final String createdAt;
  final String updatedAt;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    this.mood = 'Good',
    this.tags = const [],
    required this.date,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    String? mood,
    List<String>? tags,
    String? date,
    bool? isPinned,
    String? createdAt,
    String? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      date: date ?? this.date,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'tags': jsonEncode(tags),
      'date': date,
      'is_pinned': isPinned ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map['tags'] != null) {
      try {
        final decoded = jsonDecode(map['tags'] as String);
        if (decoded is List) {
          parsedTags = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return JournalEntry(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      mood: map['mood'] as String? ?? 'Good',
      tags: parsedTags,
      date: map['date'] as String? ?? DateTime.now().toIso8601String().substring(0, 10),
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
