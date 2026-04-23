class TransactionModel {
  final String id;
  final String type; // 'income' | 'expense'
  final double amount;
  final String category;
  final String desc;
  final DateTime date;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.desc,
    required this.date,
    required this.createdAt,
  });

  bool get isIncome  => type == 'income';
  bool get isExpense => type == 'expense';

  Map<String, dynamic> toJson() => {
    'id':        id,
    'type':      type,
    'amount':    amount,
    'category':  category,
    'desc':      desc,
    'date':      date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory TransactionModel.fromJson(Map<String, dynamic> j) => TransactionModel(
    id:        j['id'] as String,
    type:      j['type'] as String,
    amount:    (j['amount'] as num).toDouble(),
    category:  j['category'] as String,
    desc:      j['desc'] as String? ?? '',
    date:      DateTime.parse(j['date'] as String),
    createdAt: DateTime.parse(j['createdAt'] as String),
  );

  TransactionModel copyWith({
    String? id, String? type, double? amount,
    String? category, String? desc,
    DateTime? date, DateTime? createdAt,
  }) => TransactionModel(
    id:        id        ?? this.id,
    type:      type      ?? this.type,
    amount:    amount    ?? this.amount,
    category:  category  ?? this.category,
    desc:      desc      ?? this.desc,
    date:      date      ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
}

// ── Category definitions ────────────────────────────────────
class TxCategory {
  final String id;
  final String emoji;
  final String nameAr;
  final int color; // ARGB hex

  const TxCategory({
    required this.id,
    required this.emoji,
    required this.nameAr,
    required this.color,
  });
}

const List<TxCategory> kAllCategories = [
  TxCategory(id: 'food',      emoji: '🍽️', nameAr: 'طعام',      color: 0xFFFF9800),
  TxCategory(id: 'trans',     emoji: '🚗', nameAr: 'مواصلات',   color: 0xFF2196F3),
  TxCategory(id: 'shop',      emoji: '🛍️', nameAr: 'تسوق',      color: 0xFF9C27B0),
  TxCategory(id: 'health',    emoji: '💊', nameAr: 'صحة',        color: 0xFFF44336),
  TxCategory(id: 'edu',       emoji: '📚', nameAr: 'تعليم',      color: 0xFF3F51B5),
  TxCategory(id: 'fun',       emoji: '🎮', nameAr: 'ترفيه',      color: 0xFF009688),
  TxCategory(id: 'bills',     emoji: '🧾', nameAr: 'فواتير',     color: 0xFFFF5722),
  TxCategory(id: 'other',     emoji: '📦', nameAr: 'أخرى',      color: 0xFF607D8B),
  TxCategory(id: 'salary',    emoji: '💼', nameAr: 'راتب',       color: 0xFF4CAF50),
  TxCategory(id: 'invest',    emoji: '📈', nameAr: 'استثمار',    color: 0xFF00BCD4),
  TxCategory(id: 'gift',      emoji: '🎁', nameAr: 'هدية',      color: 0xFFE91E63),
  TxCategory(id: 'freelance', emoji: '💻', nameAr: 'فريلانس',   color: 0xFF8BC34A),
];

const kExpenseCats = ['food','trans','shop','health','edu','fun','bills','other'];
const kIncomeCats  = ['salary','invest','gift','freelance','other'];

TxCategory getCat(String id) =>
    kAllCategories.firstWhere((c) => c.id == id,
        orElse: () => const TxCategory(id:'other', emoji:'📦', nameAr:'أخرى', color:0xFF607D8B));
