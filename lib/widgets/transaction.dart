import 'package:intl/intl.dart';

enum TransactionType { expense, income }

class Transaction {
  final double amount;
  final TransactionType type;
  final String merchant;
  final String category;
  final DateTime dateTime;
  final String? memo;
  final bool isVault;

  Transaction({
    required this.amount,
    required this.type,
    required this.merchant,
    required this.category,
    required this.dateTime,
    this.memo,
    required this.isVault,
  });

  String get formattedAmount {
    final prefix = type == TransactionType.expense ? '-' : '+';
    return '$prefix\$${amount.toStringAsFixed(2)}';
  }

  String get formattedDate => DateFormat('MMM dd, yyyy – hh:mm a').format(dateTime);
}