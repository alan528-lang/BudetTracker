import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;

  const TransactionTile({super.key, required this.transaction, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.dateTime.toString() + transaction.merchant),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction.type == TransactionType.income ? Colors.green.shade100 : Colors.red.shade100,
            child: Icon(
              transaction.type == TransactionType.income ? Icons.arrow_upward : Icons.arrow_downward,
              color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
            ),
          ),
          title: Text(transaction.merchant, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${transaction.category} • ${transaction.formattedDate}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.formattedAmount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                ),
              ),
              if (transaction.isVault) const Icon(Icons.lock, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}