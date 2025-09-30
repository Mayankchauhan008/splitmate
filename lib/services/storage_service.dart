import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/shared_expense.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';

class StorageService {
  static const String _expensesKey = 'expenses';
  static const String _sharedExpensesKey = 'shared_expenses';
  static const String _budgetsKey = 'budgets';
  static const String _savingsGoalsKey = 'savings_goals';
  static const String _roommatesKey = 'roommates';

  // Expenses
  Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? expensesJson = prefs.getString(_expensesKey);
    if (expensesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(expensesJson);
    return decoded.map((e) => Expense.fromJson(e)).toList();
  }

  Future<void> saveExpense(Expense expense) async {
    final expenses = await getExpenses();
    expenses.add(expense);
    await _saveExpenses(expenses);
  }

  Future<void> updateExpense(Expense expense) async {
    final expenses = await getExpenses();
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
      await _saveExpenses(expenses);
    }
  }

  Future<void> deleteExpense(String id) async {
    final expenses = await getExpenses();
    expenses.removeWhere((e) => e.id == id);
    await _saveExpenses(expenses);
  }

  Future<void> _saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString(_expensesKey, encoded);
  }

  // Shared Expenses
  Future<List<SharedExpense>> getSharedExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_sharedExpensesKey);
    if (json == null) return [];

    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((e) => SharedExpense.fromJson(e)).toList();
  }

  Future<void> saveSharedExpense(SharedExpense expense) async {
    final expenses = await getSharedExpenses();
    expenses.add(expense);
    await _saveSharedExpenses(expenses);
  }

  Future<void> updateSharedExpense(SharedExpense expense) async {
    final expenses = await getSharedExpenses();
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
      await _saveSharedExpenses(expenses);
    }
  }

  Future<void> deleteSharedExpense(String id) async {
    final expenses = await getSharedExpenses();
    expenses.removeWhere((e) => e.id == id);
    await _saveSharedExpenses(expenses);
  }

  Future<void> _saveSharedExpenses(List<SharedExpense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString(_sharedExpensesKey, encoded);
  }

  // Budgets
  Future<List<Budget>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_budgetsKey);
    if (json == null) return [];

    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((e) => Budget.fromJson(e)).toList();
  }

  Future<void> saveBudget(Budget budget) async {
    final budgets = await getBudgets();
    // Remove existing budget for same category and month
    budgets.removeWhere((b) =>
        b.category == budget.category &&
        b.month.year == budget.month.year &&
        b.month.month == budget.month.month);
    budgets.add(budget);
    await _saveBudgets(budgets);
  }

  Future<void> _saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(budgets.map((e) => e.toJson()).toList());
    await prefs.setString(_budgetsKey, encoded);
  }

  // Savings Goals
  Future<List<SavingsGoal>> getSavingsGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_savingsGoalsKey);
    if (json == null) return [];

    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((e) => SavingsGoal.fromJson(e)).toList();
  }

  Future<void> saveSavingsGoal(SavingsGoal goal) async {
    final goals = await getSavingsGoals();
    goals.add(goal);
    await _saveSavingsGoals(goals);
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final goals = await getSavingsGoals();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      goals[index] = goal;
      await _saveSavingsGoals(goals);
    }
  }

  Future<void> deleteSavingsGoal(String id) async {
    final goals = await getSavingsGoals();
    goals.removeWhere((g) => g.id == id);
    await _saveSavingsGoals(goals);
  }

  Future<void> _saveSavingsGoals(List<SavingsGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(goals.map((e) => e.toJson()).toList());
    await prefs.setString(_savingsGoalsKey, encoded);
  }

  // Roommates
  Future<List<String>> getRoommates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_roommatesKey) ?? [];
  }

  Future<void> addRoommate(String name) async {
    final roommates = await getRoommates();
    if (!roommates.contains(name)) {
      roommates.add(name);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_roommatesKey, roommates);
    }
  }

  Future<void> removeRoommate(String name) async {
    final roommates = await getRoommates();
    roommates.remove(name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_roommatesKey, roommates);
  }
}