import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/savings_goal.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({Key? key}) : super(key: key);

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final _storage = StorageService();
  List<SavingsGoal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _goals = await _storage.getSavingsGoals();
    setState(() => _isLoading = false);
  }

  double get _totalSaved {
    return _goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  }

  double get _totalTarget {
    return _goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
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
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  Text(
                    'Your Goals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (_goals.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.savings_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No savings goals yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start saving for your dreams!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._goals.map((goal) {
                      return _buildGoalCard(goal);
                    }).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGoal,
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildSummaryCard() {
    final overallProgress = _totalTarget > 0 ? _totalSaved / _totalTarget : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppConstants.secondaryColor, Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.savings, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  'Total Savings',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '₹${_totalSaved.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'of ₹${_totalTarget.toStringAsFixed(2)} goal',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: overallProgress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(overallProgress * 100).toStringAsFixed(1)}% of total goals',
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

  Widget _buildGoalCard(SavingsGoal goal) {
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showGoalDetails(goal),
        borderRadius: BorderRadius.circular(12),
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
                      color: AppConstants.secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: AppConstants.secondaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (goal.description != null)
                          Text(
                            goal.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'add',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline),
                            SizedBox(width: 8),
                            Text('Add Money'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppConstants.errorColor),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppConstants.errorColor)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editGoal(goal);
                      } else if (value == 'add') {
                        _addMoney(goal);
                      } else if (value == 'delete') {
                        _deleteGoal(goal);
                      }
                    },
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
                        'Saved',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₹${goal.currentAmount.toStringAsFixed(2)}',
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
                        'Target',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₹${goal.targetAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                  value: goal.progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.progress >= 1.0
                        ? AppConstants.secondaryColor
                        : AppConstants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(goal.progress * 100).toStringAsFixed(1)}% completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isOverdue ? Icons.warning : Icons.calendar_today,
                        size: 14,
                        color: isOverdue ? AppConstants.errorColor : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverdue
                            ? 'Overdue'
                            : '$daysLeft days left',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? AppConstants.errorColor : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalDetails(SavingsGoal goal) {
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;
    final remaining = goal.targetAmount - goal.currentAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: AppConstants.secondaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (goal.description != null)
                        Text(
                          goal.description!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    'Saved',
                    '₹${goal.currentAmount.toStringAsFixed(2)}',
                    AppConstants.secondaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoTile(
                    'Target',
                    '₹${goal.targetAmount.toStringAsFixed(2)}',
                    AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    'Remaining',
                    '₹${remaining.toStringAsFixed(2)}',
                    AppConstants.warningColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoTile(
                    'Progress',
                    '${(goal.progress * 100).toStringAsFixed(1)}%',
                    AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOverdue
                    ? AppConstants.errorColor.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning : Icons.calendar_today,
                    color: isOverdue ? AppConstants.errorColor : AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOverdue ? 'Overdue!' : 'Deadline',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(goal.deadline),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!isOverdue)
                          Text(
                            '$daysLeft days remaining',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: goal.progress.clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.progress >= 1.0
                      ? AppConstants.secondaryColor
                      : AppConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _addMoney(goal);
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Money'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _addGoal() {
    _showGoalDialog();
  }

  void _editGoal(SavingsGoal goal) {
    _showGoalDialog(existingGoal: goal);
  }

  void _showGoalDialog({SavingsGoal? existingGoal}) {
    final nameController = TextEditingController(text: existingGoal?.name ?? '');
    final targetController = TextEditingController(
      text: existingGoal?.targetAmount.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingGoal?.description ?? '',
    );
    DateTime selectedDeadline = existingGoal?.deadline ?? DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingGoal == null ? 'New Savings Goal' : 'Edit Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Goal Name',
                    hintText: 'e.g., New Laptop',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  decoration: InputDecoration(
                    labelText: 'Target Amount',
                    prefixText: '₹',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Add details about your goal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDeadline = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Deadline',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('MMM dd, yyyy').format(selectedDeadline)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty || targetController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                  return;
                }

                final target = double.tryParse(targetController.text);
                if (target == null || target <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid target amount'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                  return;
                }

                final goal = existingGoal?.copyWith(
                      name: nameController.text,
                      targetAmount: target,
                      deadline: selectedDeadline,
                      description: descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                    ) ??
                    SavingsGoal(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      targetAmount: target,
                      currentAmount: 0,
                      deadline: selectedDeadline,
                      description: descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                    );

                if (existingGoal == null) {
                  await _storage.saveSavingsGoal(goal);
                } else {
                  await _storage.updateSavingsGoal(goal);
                }

                Navigator.pop(context);
                _loadData();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        existingGoal == null
                            ? 'Goal created successfully!'
                            : 'Goal updated successfully!',
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

  void _addMoney(SavingsGoal goal) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal: ${goal.name}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Current: ₹${goal.currentAmount.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount to Add',
                prefixText: '₹',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
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

              final updatedGoal = goal.copyWith(
                currentAmount: goal.currentAmount + amount,
              );

              await _storage.updateSavingsGoal(updatedGoal);
              Navigator.pop(context);
              _loadData();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('₹${amount.toStringAsFixed(2)} added to ${goal.name}'),
                    backgroundColor: AppConstants.secondaryColor,
                  ),
                );

                // Check if goal is completed
                if (updatedGoal.currentAmount >= updatedGoal.targetAmount) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      _showGoalCompletedDialog(updatedGoal);
                    }
                  });
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showGoalCompletedDialog(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppConstants.secondaryColor, size: 32),
            SizedBox(width: 12),
            Text('Congratulations!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'ve reached your savings goal for "${goal.name}"!',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Saved: ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '₹${goal.currentAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(SavingsGoal goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.name}"?'),
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
      await _storage.deleteSavingsGoal(goal.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal deleted')),
        );
      }
    }
  }
}