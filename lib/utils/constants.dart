import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);
  
  // Expense Categories
  static const List<String> expenseCategories = [
    'Food',
    'Books',
    'Transport',
    'Entertainment',
    'Shopping',
    'Bills',
    'Healthcare',
    'Others',
  ];
  
  // Category Icons
  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Books': Icons.book,
    'Transport': Icons.directions_bus,
    'Entertainment': Icons.movie,
    'Shopping': Icons.shopping_bag,
    'Bills': Icons.receipt,
    'Healthcare': Icons.medical_services,
    'Others': Icons.category,
  };
  
  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFFFF6B6B),
    'Books': Color(0xFF4ECDC4),
    'Transport': Color(0xFFFFE66D),
    'Entertainment': Color(0xFFA8E6CF),
    'Shopping': Color(0xFFFF8B94),
    'Bills': Color(0xFFC7CEEA),
    'Healthcare': Color(0xFFFFAFCC),
    'Others': Color(0xFFB4A7D6),
  };
}