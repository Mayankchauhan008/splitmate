import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppConstants.categoryIcons[category],
              size: 16,
              color: isSelected ? Colors.white : AppConstants.categoryColors[category],
            ),
            const SizedBox(width: 6),
            Text(category),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: AppConstants.categoryColors[category]?.withOpacity(0.2),
        selectedColor: AppConstants.categoryColors[category],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }
}