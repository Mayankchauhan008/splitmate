import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';
import '../widgets/expense_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/chart_widget.dart';
import '../utils/constants.dart';
import 'add_expense_screen.dart';
import 'shared_expenses_screen.dart';
import 'budget_screen.dart';
import 'savings_goals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<Expense> _expenses = [];
  List<Budget> _budgets = [];
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _expenses = await _storage.getExpenses();
    _budgets = await _storage.getBudgets();
    _checkBudgetAlerts();
    setState(() => _isLoading = false);
  }

  void _checkBudgetAlerts() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    for (var budget in _budgets) {
      if (budget.month.year == currentMonth.year &&
          budget.month.month == currentMonth.month) {
        final spent = _getSpentForCategory(budget.category, currentMonth);
        if (spent >= budget.amount * 0.9) {
          _showBudgetAlert(budget.category, spent, budget.amount);
        }
      }
    }
  }

  double _getSpentForCategory(String category, DateTime month) {
    return _expenses
        .where((e) =>
            e.category == category &&
            e.date.year == month.year &&
            e.date.month == month.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  void _showBudgetAlert(String category, double spent, double budget) {
    final percentage = (spent / budget * 100).toStringAsFixed(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ You\'ve spent $percentage% of your $category budget!',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppConstants.warningColor,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BudgetScreen()),
                );
              },
            ),
          ),
        );
      }
    });
  }

  List<Expense> get _filteredExpenses {
    if (_selectedCategory == null) return _expenses;
    return _expenses.where((e) => e.category == _selectedCategory).toList();
  }

  double get _totalExpenses {
    return _filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get _categoryTotals {
    final Map<String, double> totals = {};
    for (var expense in _expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildSummaryCard()),
                  SliverToBoxAdapter(child: _buildChartSection()),
                  SliverToBoxAdapter(child: _buildCategoryFilter()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Recent Expenses',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  _filteredExpenses.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No expenses yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final expense = _filteredExpenses[index];
                              return ExpenseCard(
                                expense: expense,
                                onDelete: () => _deleteExpense(expense.id),
                              );
                            },
                            childCount: _filteredExpenses.length,
                          ),
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppConstants.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.account_balance_wallet, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'Student Expense Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Shared Expenses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SharedExpensesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Budget Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.savings),
            title: const Text('Savings Goals'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryColor, Color(0xFF8B7FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Expenses',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_totalExpenses.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    if (_categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ExpenseChart(categoryTotals: _categoryTotals),
            const SizedBox(height: 16),
            ..._categoryTotals.entries.map((entry) {
              final percentage = (entry.value / _totalExpenses * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppConstants.categoryColors[entry.key],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entry.key),
                    ),
                    Text(
                      '₹${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: _selectedCategory == null,
              onSelected: (_) {
                setState(() => _selectedCategory = null);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppConstants.primaryColor,
              labelStyle: TextStyle(
                color: _selectedCategory == null ? Colors.white : Colors.black87,
                fontWeight: _selectedCategory == null ? FontWeight.w600 : FontWeight.normal,
              ),
              checkmarkColor: Colors.white,
            ),
          ),
          ...AppConstants.expenseCategories.map((category) {
            return CategoryChip(
              category: category,
              isSelected: _selectedCategory == category,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _deleteExpense(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppConstants.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.deleteExpense(id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted')),
        );
      }
    }
  }
}