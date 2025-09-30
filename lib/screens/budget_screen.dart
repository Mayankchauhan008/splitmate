import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _storage = StorageService();
  List<Budget> _budgets = [];
  List<Expense> _expenses = [];
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _budgets = await _storage.getBudgets();
    _expenses = await _storage.getExpenses();
    setState(() => _isLoading = false);
  }

  List<Budget> get _currentMonthBudgets {
    return _budgets.where((b) {
      return b.month.year == _selectedMonth.year &&
          b.month.month == _selectedMonth.month;
    }).toList();
  }

  double _getSpentForCategory(String category) {
    return _expenses
        .where((e) =>
            e.category == category &&
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get _totalBudget {
    return _currentMonthBudgets.fold(0.0, (sum, b) => sum + b.amount);
  }

  double get _totalSpent {
    return _expenses
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMonthSelector(),
                  const SizedBox(height: 16),
                  _buildOverallBudgetCard(),
                  const SizedBox(height: 16),
                  Text(
                    'Category Budgets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (_currentMonthBudgets.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_balance_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No budgets set for this month',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._currentMonthBudgets.map((budget) {
                      return _buildBudgetCard(budget);
                    }).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBudget,
        icon: const Icon(Icons.add),
        label: const Text('Set Budget'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                final now = DateTime.now();
                final nextMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
                if (nextMonth.isBefore(now) ||
                    (nextMonth.year == now.year && nextMonth.month == now.month)) {
                  setState(() {
                    _selectedMonth = nextMonth;
                  });
                }
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallBudgetCard() {
    final remaining = _totalBudget - _totalSpent;
    final percentage = _totalBudget > 0 ? (_totalSpent / _totalBudget) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Budget',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${_totalBudget.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spent',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '₹${_totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '₹${remaining.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white30,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 0.9
                      ? AppConstants.errorColor
                      : percentage > 0.7
                          ? AppConstants.warningColor
                          : AppConstants.secondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}% used',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final spent = _getSpentForCategory(budget.category);
    final remaining = budget.amount - spent;
    final percentage = spent / budget.amount;

    Color progressColor;
    if (percentage >= 1.0) {
      progressColor = AppConstants.errorColor;
    } else if (percentage >= 0.9) {
      progressColor = AppConstants.warningColor;
    } else {
      progressColor = AppConstants.secondaryColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppConstants.categoryColors[budget.category]?.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    AppConstants.categoryIcons[budget.category],
                    color: AppConstants.categoryColors[budget.category],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Budget: ₹${budget.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: AppConstants.primaryColor,
                  onPressed: () => _editBudget(budget),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '₹${spent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '₹${remaining.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: remaining < 0 ? AppConstants.errorColor : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}% used',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addBudget() {
    _showBudgetDialog();
  }

  void _editBudget(Budget budget) {
    _showBudgetDialog(existingBudget: budget);
  }

  void _showBudgetDialog({Budget? existingBudget}) {
    final amountController = TextEditingController(
      text: existingBudget?.amount.toString() ?? '',
    );
    String selectedCategory = existingBudget?.category ?? AppConstants.expenseCategories.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingBudget == null ? 'Set Budget' : 'Edit Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: AppConstants.expenseCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(
                          AppConstants.categoryIcons[category],
                          size: 20,
                          color: AppConstants.categoryColors[category],
                        ),
                        const SizedBox(width: 12),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedCategory = value!);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: '₹',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              Text(
                'For ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (amountController.text.isEmpty) {
                  return;
                }

                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                  return;
                }

                final budget = Budget(
                  category: selectedCategory,
                  amount: amount,
                  month: DateTime(_selectedMonth.year, _selectedMonth.month),
                );

                await _storage.saveBudget(budget);
                Navigator.pop(context);
                _loadData();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        existingBudget == null
                            ? 'Budget set successfully!'
                            : 'Budget updated successfully!',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}