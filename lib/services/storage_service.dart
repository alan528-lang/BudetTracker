import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const _uuid = Uuid();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Auth ──────────────────────────────────────────────────

  static String _hashPass(String pass) =>
      sha256.convert(utf8.encode(pass)).toString();

  static Future<bool> register({
    required String username,
    required String name,
    required String password,
  }) async {
    final users = _loadUsers();
    if (users.containsKey(username)) return false;
    users[username] = UserModel(
      username:   username,
      name:       name,
      hashedPass: _hashPass(password),
      since:      DateTime.now(),
    );
    await _saveUsers(users);
    await setCurrentUser(username);
    return true;
  }

  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    final users = _loadUsers();
    final user = users[username];
    if (user == null) return false;
    if (user.hashedPass != _hashPass(password)) return false;
    await setCurrentUser(username);
    return true;
  }

  static Future<void> logout() async {
    await _prefs!.remove('current_user');
  }

  static String? getCurrentUser()     => _prefs!.getString('current_user');
  static Future<void> setCurrentUser(String u) =>
      _prefs!.setString('current_user', u);

  static UserModel? getUserInfo([String? username]) {
    final u = username ?? getCurrentUser();
    if (u == null) return null;
    return _loadUsers()[u];
  }

  static bool userExists(String username) => _loadUsers().containsKey(username);

  // ── Transactions ─────────────────────────────────────────

  static List<TransactionModel> getTransactions([String? username]) {
    final u = username ?? getCurrentUser();
    if (u == null) return [];
    final raw = _prefs!.getString('txs_$u');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> addTransaction({
    required String type,
    required double amount,
    required String category,
    String desc = '',
  }) async {
    final txs = getTransactions();
    txs.insert(0, TransactionModel(
      id:        _uuid.v4(),
      type:      type,
      amount:    amount,
      category:  category,
      desc:      desc,
      date:      DateTime.now(),
      createdAt: DateTime.now(),
    ));
    await _saveTxs(txs);
  }

  static Future<void> deleteTransaction(String id) async {
    final txs = getTransactions()..removeWhere((t) => t.id == id);
    await _saveTxs(txs);
  }

  static Future<void> clearTransactions() async {
    await _saveTxs([]);
  }

  // ── Demo data ─────────────────────────────────────────────

  static Future<void> seedDemoData() async {
    final now = DateTime.now();
    await _saveTxs([
      TransactionModel(id: _uuid.v4(), type: 'income',  amount: 750000, category: 'salary',    desc: 'راتب شهر مارس',   date: now.subtract(const Duration(days: 14)), createdAt: now.subtract(const Duration(days: 14))),
      TransactionModel(id: _uuid.v4(), type: 'expense', amount: 85000,  category: 'food',      desc: 'سوبرماركت',      date: now.subtract(const Duration(days: 10)), createdAt: now.subtract(const Duration(days: 10))),
      TransactionModel(id: _uuid.v4(), type: 'expense', amount: 45000,  category: 'trans',     desc: 'بنزين',           date: now.subtract(const Duration(days: 8)),  createdAt: now.subtract(const Duration(days: 8))),
      TransactionModel(id: _uuid.v4(), type: 'expense', amount: 120000, category: 'bills',     desc: 'فاتورة كهرباء',  date: now.subtract(const Duration(days: 5)),  createdAt: now.subtract(const Duration(days: 5))),
      TransactionModel(id: _uuid.v4(), type: 'income',  amount: 200000, category: 'freelance', desc: 'مشروع موقع ويب', date: now.subtract(const Duration(days: 3)),  createdAt: now.subtract(const Duration(days: 3))),
      TransactionModel(id: _uuid.v4(), type: 'expense', amount: 35000,  category: 'fun',       desc: 'اشتراكات',       date: now.subtract(const Duration(days: 2)),  createdAt: now.subtract(const Duration(days: 2))),
      TransactionModel(id: _uuid.v4(), type: 'expense', amount: 60000,  category: 'health',    desc: 'صيدلية',         date: now.subtract(const Duration(days: 1)),  createdAt: now.subtract(const Duration(days: 1))),
    ]);
  }

  // ── Private helpers ───────────────────────────────────────

  static Map<String, UserModel> _loadUsers() {
    final raw = _prefs!.getString('users');
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, UserModel.fromJson(v as Map<String, dynamic>)));
  }

  static Future<void> _saveUsers(Map<String, UserModel> users) async {
    await _prefs!.setString('users', jsonEncode(users.map((k, v) => MapEntry(k, v.toJson()))));
  }

  static Future<void> _saveTxs(List<TransactionModel> txs) async {
    final u = getCurrentUser();
    if (u == null) return;
    await _prefs!.setString('txs_$u', jsonEncode(txs.map((t) => t.toJson()).toList()));
  }
}
