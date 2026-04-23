import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class TransactionForm extends StatefulWidget {
  final void Function(Transaction) onAddTransaction;

  const TransactionForm({super.key, required this.onAddTransaction});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();

  String _amountStr = '';
  TransactionType _type = TransactionType.expense;
  String _merchant = '';
  String? _category;
  DateTime _dateTime = DateTime.now();
  String _memo = '';
  // Removed _isVault as toggle, making it the submit action

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.bg,
              surface: AppColors.card,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.accent,
                onPrimary: AppColors.bg,
                surface: AppColors.card,
                onSurface: AppColors.text,
              ),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() {
          _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _category != null) {
      _formKey.currentState!.save();
      final double amount = double.tryParse(_amountStr) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: AppColors.red),
        );
        return;
      }

      final transaction = Transaction(
        amount: amount,
        type: _type,
        merchant: _merchant,
        category: _category!,
        dateTime: _dateTime,
        memo: _memo.isEmpty ? null : _memo,
        isVault: true, // As per UI text "Add to Vault"
      );
      widget.onAddTransaction(transaction);
      
      // Auto-pop or reset handled by parent if needed, but let's just pop
      Navigator.of(context).pop();
    } else if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category', style: TextStyle(color: AppColors.red)), 
          backgroundColor: AppColors.redBg
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration({required String hintText, Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.text2, fontSize: 16),
      filled: true,
      fillColor: const Color(0xFF2A2E36), // Darker grey-blue for fields
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.text2,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Amount Section
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'AMOUNT',
              style: TextStyle(
                color: AppColors.text2,
                fontSize: 13,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '\$',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              IntrinsicWidth(
                child: TextFormField(
                  initialValue: _amountStr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: AppColors.text2,
                      fontSize: 64,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => _amountStr = val,
                  onSaved: (val) => _amountStr = val ?? '',
                  validator: (val) => (val == null || val.isEmpty) ? '' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Toggle Button
          Center(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1D2229),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleSegment(
                    title: 'Expense',
                    isSelected: _type == TransactionType.expense,
                    onTap: () => setState(() => _type = TransactionType.expense),
                  ),
                  _buildToggleSegment(
                    title: 'Income',
                    isSelected: _type == TransactionType.income,
                    onTap: () => setState(() => _type = TransactionType.income),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Form Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF22272F), // Card background mapping
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('MERCHANT / PAYEE'),
                TextFormField(
                  initialValue: _merchant,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _buildInputDecoration(
                    hintText: 'e.g. Whole Foods',
                    prefixIcon: const Icon(Icons.storefront, color: AppColors.text2),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                  onSaved: (value) => _merchant = value!,
                ),
                const SizedBox(height: 24),

                _buildFieldLabel('CATEGORY'),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.text2),
                  dropdownColor: const Color(0xFF2A2E36),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  items: categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) => setState(() => _category = value),
                  decoration: _buildInputDecoration(
                    hintText: 'Select Category',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(38),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.category, color: AppColors.accent, size: 18),
                      ),
                    ),
                  ).copyWith(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 24),

                _buildFieldLabel('DATE & TIME'),
                InkWell(
                  onTap: _selectDateTime,
                  borderRadius: BorderRadius.circular(12),
                  child: IgnorePointer(
                    child: TextFormField(
                      key: ValueKey(_dateTime),
                      initialValue: DateFormat('MM/dd/yyyy, hh:mm a').format(_dateTime),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: _buildInputDecoration(
                        hintText: 'mm/dd/yyyy, --:-- --',
                        prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.text2, size: 20),
                        suffixIcon: const Icon(Icons.calendar_month, color: AppColors.text2, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildFieldLabel('MEMO / NOTES'),
                TextFormField(
                  initialValue: _memo,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _buildInputDecoration(
                    hintText: 'Add details...',
                  ),
                  onSaved: (value) => _memo = value ?? '',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Submit Button
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Add to Vault',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 32), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildToggleSegment({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38404B) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.text2,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}