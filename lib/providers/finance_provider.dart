import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/transaction_item.dart';
import '../models/budget.dart';
import '../services/csv_export_service.dart';

class FinanceProvider extends ChangeNotifier {
  List<TransactionItem> _transactions = [];
  List<Budget> _budgets = [];
  bool _isLoading = true;
  String _selectedCategoryFilter = 'All';

  List<TransactionItem> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String get selectedCategoryFilter => _selectedCategoryFilter;

  FinanceProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await DBHelper.instance.getTransactions();
    _budgets = await DBHelper.instance.getBudgets();

    _isLoading = false;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  List<TransactionItem> get filteredTransactions {
    if (_selectedCategoryFilter == 'All') return _transactions;
    if (_selectedCategoryFilter == 'Income') {
      return _transactions.where((t) => t.isIncome).toList();
    }
    if (_selectedCategoryFilter == 'Expense') {
      return _transactions.where((t) => t.isExpense).toList();
    }
    return _transactions.where((t) => t.category == _selectedCategoryFilter).toList();
  }

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get netBalance => totalIncome - totalExpense;

  Map<String, double> get categoryExpenses {
    final Map<String, double> map = {};
    for (var tx in _transactions.where((t) => t.isExpense)) {
      map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
    }
    return map;
  }

  double get totalBudgetLimit =>
      _budgets.fold(0.0, (sum, b) => sum + b.monthlyLimit);

  double get budgetSpentPercentage {
    if (totalBudgetLimit == 0) return 0.0;
    final pct = totalExpense / totalBudgetLimit;
    return pct > 1.0 ? 1.0 : pct;
  }

  double getSpentForCategory(String category) {
    return _transactions
        .where((t) => t.isExpense && t.category == category)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getBudgetForCategory(String category) {
    final match = _budgets.firstWhere(
      (b) => b.category.toLowerCase() == category.toLowerCase(),
      orElse: () => Budget(category: category, monthlyLimit: 0.0),
    );
    return match.monthlyLimit;
  }

  Future<void> addTransaction(TransactionItem item) async {
    _transactions.insert(0, item);
    notifyListeners();
    await DBHelper.instance.insertTransaction(item);
  }

  Future<void> updateTransaction(TransactionItem item) async {
    final index = _transactions.indexWhere((t) => t.id == item.id);
    if (index != -1) {
      _transactions[index] = item;
      notifyListeners();
      await DBHelper.instance.updateTransaction(item);
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await DBHelper.instance.deleteTransaction(id);
  }

  Future<void> setCategoryBudget(String category, double limit) async {
    final budget = Budget(category: category, monthlyLimit: limit);
    final index = _budgets.indexWhere((b) => b.category == category);
    if (index != -1) {
      _budgets[index] = budget;
    } else {
      _budgets.add(budget);
    }
    notifyListeners();
    await DBHelper.instance.setBudget(budget);
  }

  Future<String> exportCsv() async {
    return await CsvExportService.exportTransactions(_transactions);
  }
}
