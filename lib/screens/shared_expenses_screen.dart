import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shared_expense.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class SharedExpensesScreen extends StatefulWidget {
  const SharedExpensesScreen({Key? key}) : super(key: key);

  @override
  State<SharedExpensesScreen> createState() => _SharedExpensesScreenState();
}

class _SharedExpensesScreenState extends State<SharedExpensesScreen> {
  final _storage = StorageService();
  List<SharedExpense> _sharedExpenses = [];
  List<String> _roommates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _sharedExpenses = await _storage.getSharedExpenses();
    _roommates = await _storage.getRoommates();
    setState(() => _isLoading = false);
  }

  Map<String, double> _calculateBalances() {
    final Map<String, double> balances = {};

    for (var expense in _sharedExpenses) {
      if (expense.isSettled) continue;

      for (var participant in expense.participants) {
        balances[participant] = (balances[participant] ?? 0);
      }

      balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.totalAmount;

      expense.splits.forEach((person, amount) {
        balances[person] = (balances[person] ?? 0) - amount;
      });
    }

    return balances;
  }

  @override
  Widget build(BuildContext context) {
    final balances = _calculateBalances();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Expenses'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _manageRoommates,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBalanceCard(balances),
                  const SizedBox(height: 16),
                  Text(
                    'Shared Expenses',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (_sharedExpenses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No shared expenses yet',
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
                    ..._sharedExpenses.map((expense) {
                      return _buildSharedExpenseCard(expense);
                    }).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _roommates.isEmpty ? _showAddRoommatesFirst : _addSharedExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildBalanceCard(Map<String, double> balances) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Current Balances',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (balances.isEmpty)
              const Text('No balances to show')
            else
              ...balances.entries.map((entry) {
                final amount = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
                            child: Text(
                              entry.key[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        amount >= 0
                            ? '+₹${amount.toStringAsFixed(2)}'
                            : '-₹${(-amount).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: amount >= 0
                              ? AppConstants.secondaryColor
                              : AppConstants.errorColor,
                        ),
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

  Widget _buildSharedExpenseCard(SharedExpense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: expense.isSettled
              ? Colors.grey[300]
              : AppConstants.primaryColor.withOpacity(0.2),
          child: Icon(
            expense.isSettled ? Icons.check_circle : Icons.people,
            color: expense.isSettled ? Colors.grey : AppConstants.primaryColor,
          ),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Paid by ${expense.paidBy}'),
            Text(
              DateFormat('MMM dd, yyyy').format(expense.date),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${expense.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (expense.isSettled)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppConstants.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Settled',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showExpenseDetails(expense),
      ),
    );
  }

  void _showExpenseDetails(SharedExpense expense) {
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
            Text(
              expense.description,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ₹${expense.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Paid by ${expense.paidBy} on ${DateFormat('MMM dd, yyyy').format(expense.date)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 32),
            Text(
              'Split Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...expense.splits.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 16)),
                    Text(
                      '₹${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            if (!expense.isSettled)
              ElevatedButton(
                onPressed: () async {
                  await _storage.updateSharedExpense(
                    expense.copyWith(isSettled: true),
                  );
                  Navigator.pop(context);
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expense marked as settled')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Mark as Settled',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Expense'),
                    content: const Text('Are you sure you want to delete this shared expense?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppConstants.errorColor,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await _storage.deleteSharedExpense(expense.id);
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense deleted')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.errorColor,
                side: const BorderSide(color: AppConstants.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete Expense',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRoommatesFirst() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Roommates First'),
        content: const Text(
          'You need to add roommates before creating shared expenses. Would you like to add them now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _manageRoommates();
            },
            child: const Text('Add Roommates'),
          ),
        ],
      ),
    );
  }

  void _manageRoommates() {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
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
              Text(
                'Manage Roommates',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Roommate name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty) {
                        await _storage.addRoommate(nameController.text);
                        nameController.clear();
                        _loadData();
                      }
                    },
                    icon: const Icon(Icons.add_circle),
                    color: AppConstants.primaryColor,
                    iconSize: 36,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              if (_roommates.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No roommates added yet'),
                  ),
                )
              else
                ..._roommates.map((roommate) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
                      child: Text(
                        roommate[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(roommate),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppConstants.errorColor,
                      onPressed: () async {
                        await _storage.removeRoommate(roommate);
                        _loadData();
                      },
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _addSharedExpense() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String paidBy = _roommates.first;
    final selectedParticipants = <String>{... _roommates};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
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
                Text(
                  'Add Shared Expense',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g., Grocery shopping',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Total Amount',
                    prefixText: '₹',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: paidBy,
                  decoration: InputDecoration(
                    labelText: 'Paid By',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _roommates.map((roommate) {
                    return DropdownMenuItem(
                      value: roommate,
                      child: Text(roommate),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setModalState(() => paidBy = value!);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Split Between',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ..._roommates.map((roommate) {
                  return CheckboxListTile(
                    title: Text(roommate),
                    value: selectedParticipants.contains(roommate),
                    onChanged: (value) {
                      setModalState(() {
                        if (value == true) {
                          selectedParticipants.add(roommate);
                        } else {
                          selectedParticipants.remove(roommate);
                        }
                      });
                    },
                    activeColor: AppConstants.primaryColor,
                  );
                }).toList(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (descriptionController.text.isEmpty ||
                        amountController.text.isEmpty ||
                        selectedParticipants.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: AppConstants.errorColor,
                        ),
                      );
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

                    // Split equally
                    final splitAmount = amount / selectedParticipants.length;
                    final splits = <String, double>{};
                    for (var participant in selectedParticipants) {
                      splits[participant] = splitAmount;
                    }

                    final expense = SharedExpense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      description: descriptionController.text,
                      totalAmount: amount,
                      paidBy: paidBy,
                      participants: selectedParticipants.toList(),
                      splits: splits,
                      date: DateTime.now(),
                    );

                    await _storage.saveSharedExpense(expense);
                    Navigator.pop(context);
                    _loadData();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shared expense added successfully!'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Expense',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}