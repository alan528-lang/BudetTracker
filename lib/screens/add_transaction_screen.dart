import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  void _addTransaction(Transaction transaction) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Transaction added successfully!')),
    // );
    // Custom logic to save transaction and close the screen
    debugPrint('Transaction Added: ${transaction.amount} - ${transaction.merchant}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101418), // Based on the screenshot's darker background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Transaction',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: TransactionForm(onAddTransaction: _addTransaction),
      ),
    );
  }
}