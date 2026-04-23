import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel tx;
  final bool showDelete;

  const TransactionCard({super.key, required this.tx, this.showDelete = false});

  String _fmt(double n) {
    if (n.abs() >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M';
    if (n.abs() >= 1e3) return '${(n / 1e3).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    return n.round().toString();
  }

  String _fmtDate(DateTime d) {
    final months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو',
                    'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final cat   = getCat(tx.category);
    final color = Color(cat.color);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Side accent bar
            Positioned(
              right: 0, top: 0, bottom: 0,
              child: Container(
                width: 3,
                color: tx.isIncome ? AppColors.accent : AppColors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.desc.isNotEmpty ? tx.desc : cat.nameAr,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.card2,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(cat.nameAr,
                                  style: const TextStyle(
                                      fontSize: 10, color: AppColors.text2,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 6),
                            Text(_fmtDate(tx.date),
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.text3)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Amount + delete
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${tx.isIncome ? '+' : '-'} ${_fmt(tx.amount)}',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: tx.isIncome ? AppColors.accent : AppColors.red,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (showDelete) ...[
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _confirmDelete(context),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.redBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                size: 15, color: AppColors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('حذف العملية؟',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('لا يمكن التراجع عن هذا الإجراء.',
            style: TextStyle(color: AppColors.text2, fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.text2, fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<AppState>().deleteTransaction(tx.id);
            },
            child: const Text('حذف',
                style: TextStyle(color: AppColors.red, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
