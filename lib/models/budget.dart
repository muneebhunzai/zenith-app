class Budget {
  final String category;
  final double monthlyLimit;

  Budget({
    required this.category,
    required this.monthlyLimit,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'monthly_limit': monthlyLimit,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      category: map['category'] as String,
      monthlyLimit: (map['monthly_limit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
