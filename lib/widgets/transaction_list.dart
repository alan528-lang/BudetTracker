import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'transaction_tile.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(int) onDelete;

  const TransactionList({super.key, required this.transactions, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No transactions yet.\nAdd your first transaction above.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (ctx, index) {
        return TransactionTile(
          transaction: transactions[index],
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}