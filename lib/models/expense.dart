class Expense {
  final String id;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }

  Expense copyWith({
    String? id,
    String? category,
    double? amount,
    String? description,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}