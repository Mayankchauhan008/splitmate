class Budget {
  final String category;
  final double amount;
  final DateTime month;

  Budget({
    required this.category,
    required this.amount,
    required this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'month': month.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: json['category'],
      amount: json['amount'].toDouble(),
      month: DateTime.parse(json['month']),
    );
  }
}