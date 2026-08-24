class TransactionItem {
  final String id;
  final String type; // 'income' or 'expense'
  final double amount;
  final String category; // 'Food', 'Transport', 'Bills', 'Shopping', 'Salary', 'Investment', 'Health', etc.
  final String date; // 'YYYY-MM-DD'
  final String note;
  final String createdAt;

  TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
    required this.createdAt,
  });

  bool get isExpense => type.toLowerCase() == 'expense';
  bool get isIncome => type.toLowerCase() == 'income';

  TransactionItem copyWith({
    String? id,
    String? type,
    double? amount,
    String? category,
    String? date,
    String? note,
    String? createdAt,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'date': date,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as String,
      type: map['type'] as String? ?? 'expense',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? 'General',
      date: map['date'] as String? ?? DateTime.now().toIso8601String().substring(0, 10),
      note: map['note'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
