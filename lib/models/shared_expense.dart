class SharedExpense {
  final String id;
  final String description;
  final double totalAmount;
  final String paidBy;
  final List<String> participants;
  final Map<String, double> splits;
  final DateTime date;
  final bool isSettled;

  SharedExpense({
    required this.id,
    required this.description,
    required this.totalAmount,
    required this.paidBy,
    required this.participants,
    required this.splits,
    required this.date,
    this.isSettled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'totalAmount': totalAmount,
      'paidBy': paidBy,
      'participants': participants,
      'splits': splits,
      'date': date.toIso8601String(),
      'isSettled': isSettled,
    };
  }

  factory SharedExpense.fromJson(Map<String, dynamic> json) {
    return SharedExpense(
      id: json['id'],
      description: json['description'],
      totalAmount: json['totalAmount'].toDouble(),
      paidBy: json['paidBy'],
      participants: List<String>.from(json['participants']),
      splits: Map<String, double>.from(
        (json['splits'] as Map).map(
          (key, value) => MapEntry(key.toString(), value.toDouble()),
        ),
      ),
      date: DateTime.parse(json['date']),
      isSettled: json['isSettled'] ?? false,
    );
  }

  SharedExpense copyWith({
    String? id,
    String? description,
    double? totalAmount,
    String? paidBy,
    List<String>? participants,
    Map<String, double>? splits,
    DateTime? date,
    bool? isSettled,
  }) {
    return SharedExpense(
      id: id ?? this.id,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      paidBy: paidBy ?? this.paidBy,
      participants: participants ?? this.participants,
      splits: splits ?? this.splits,
      date: date ?? this.date,
      isSettled: isSettled ?? this.isSettled,
    );
  }
}