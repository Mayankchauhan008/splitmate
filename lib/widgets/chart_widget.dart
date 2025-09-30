import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const ExpenseChart({Key? key, required this.categoryTotals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text('No expense data available'),
      );
    }

    final total = categoryTotals.values.reduce((a, b) => a + b);

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: categoryTotals.entries.map((entry) {
            final percentage = (entry.value / total * 100);
            return PieChartSectionData(
              value: entry.value,
              title: '${percentage.toStringAsFixed(1)}%',
              color: AppConstants.categoryColors[entry.key],
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}