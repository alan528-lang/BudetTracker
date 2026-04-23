import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  UserModel? _user;

  List<TransactionModel> get transactions => _transactions;
  UserModel?             get user         => _user;

  double get totalIncome  => _transactions.where((t) => t.isIncome ).fold(0, (a, b) => a + b.amount);
  double get totalExpense => _transactions.where((t) => t.isExpense).fold(0, (a, b) => a + b.amount);
  double get balance      => totalIncome - totalExpense;

  void loadUser() {
    _user = StorageService.getUserInfo();
    notifyListeners();
  }

  void loadTransactions() {
    _transactions = StorageService.getTransactions();
    notifyListeners();
  }

  void refresh() {
    loadUser();
    loadTransactions();
  }

  Future<void> addTransaction({
    required String type,
    required double amount,
    required String category,
    String desc = '',
  }) async {
    await StorageService.addTransaction(
      type: type, amount: amount, category: category, desc: desc,
    );
    loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await StorageService.deleteTransaction(id);
    loadTransactions();
  }

  Future<void> clearAll() async {
    await StorageService.clearTransactions();
    loadTransactions();
  }

  void clearUser() {
    _user = null;
    _transactions = [];
    notifyListeners();
  }

  // ── Filtered helpers ─────────────────────────────────────

  List<TransactionModel> filtered({
    String? type,
    String? query,
    int? months,
  }) {
    var list = [..._transactions];

    if (type != null && type != 'all') {
      list = list.where((t) => t.type == type).toList();
    }

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((t) {
        final cat = getCat(t.category);
        return t.desc.toLowerCase().contains(q) || cat.nameAr.contains(q);
      }).toList();
    }

    if (months != null && months > 0) {
      final cutoff = DateTime.now().subtract(Duration(days: months * 30));
      list = list.where((t) => t.date.isAfter(cutoff)).toList();
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Map<String, List<TransactionModel>> groupByDate(List<TransactionModel> txs) {
    final map = <String, List<TransactionModel>>{};
    for (final tx in txs) {
      final key = '${tx.date.year}-${tx.date.month.toString().padLeft(2,'0')}-${tx.date.day.toString().padLeft(2,'0')}';
      map.putIfAbsent(key, () => []).add(tx);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }
}
