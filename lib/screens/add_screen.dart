import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class AddScreen extends StatefulWidget {
  final String initialType;
  const AddScreen({super.key, this.initialType = 'expense'});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  late String _type;
  String _amtStr = '';
  String _selCat = 'food';
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _selCat = _type == 'expense' ? 'food' : 'salary';
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  List<TxCategory> get _cats =>
      (_type == 'expense' ? kExpenseCats : kIncomeCats)
          .map((id) => getCat(id))
          .toList();

  void _handleNum(String k) {
    HapticFeedback.lightImpact();
    setState(() {
      if (k == '⌫') {
        if (_amtStr.isNotEmpty) _amtStr = _amtStr.substring(0, _amtStr.length - 1);
      } else if (k == '000') {
        if (_amtStr.isNotEmpty && _amtStr != '0') _amtStr += '000';
      } else {
        if (_amtStr.length < 10) _amtStr += k;
      }
    });
  }

  String get _displayAmt {
    if (_amtStr.isEmpty) return '0';
    return int.tryParse(_amtStr)?.toString() ?? '0';
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_amtStr) ?? 0;
    if (amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل مبلغاً صحيحاً', style: TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    await context.read<AppState>().addTransaction(
      type:     _type,
      amount:   amt,
      category: _selCat,
      desc:     _descCtrl.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('back'),),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle + close
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.close_rounded, color: AppColors.text2, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _type == 'expense' ? 'إضافة مصروف' : 'إضافة دخل',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 16),
      
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Type switch
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            _TypeBtn(
                              label: 'مصروف', selected: _type == 'expense',
                              activeColor: AppColors.red,
                              onTap: () => setState(() { _type = 'expense'; _selCat = 'food'; }),
                            ),
                            _TypeBtn(
                              label: 'دخل', selected: _type == 'income',
                              activeColor: AppColors.accent,
                              onTap: () => setState(() { _type = 'income'; _selCat = 'salary'; }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
      
                    // Amount display
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Text('المبلغ',
                              style: TextStyle(fontSize: 12, color: AppColors.text2,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text('IQD ',
                                  style: TextStyle(fontSize: 20, color: AppColors.text3)),
                              Text(
                                _displayAmt,
                                style: TextStyle(
                                  fontSize: 44, fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace', letterSpacing: -2,
                                  color: _amtStr.isNotEmpty
                                      ? AppColors.accent
                                      : AppColors.text,
                                ),
                              ),
                              const Text(' |',
                                  style: TextStyle(
                                      fontSize: 36, color: AppColors.accent)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
      
                    // Categories
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الفئة',
                              style: TextStyle(fontSize: 12, color: AppColors.text2,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _cats.length,
                            itemBuilder: (_, i) {
                              final cat = _cats[i];
                              final sel = _selCat == cat.id;
                              return GestureDetector(
                                onTap: () { HapticFeedback.selectionClick(); setState(() => _selCat = cat.id); },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  decoration: BoxDecoration(
                                    color: sel ? AppColors.accentBg : AppColors.card,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: sel
                                          ? AppColors.accent.withOpacity(0.4)
                                          : AppColors.border,
                                      width: sel ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                                      const SizedBox(height: 4),
                                      Text(cat.nameAr,
                                          style: TextStyle(
                                              fontSize: 10, fontWeight: FontWeight.w600,
                                              color: sel ? AppColors.accent : AppColors.text2),
                                          textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
      
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _descCtrl,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(color: AppColors.text, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'وصف اختياري...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
      
                    // Numpad
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _Numpad(
                        onKey: _handleNum,
                        type: _type,
                        onSubmit: _submit,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Type button ───────────────────────────────────────────────────────────────
class _TypeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeBtn({
    required this.label, required this.selected,
    required this.activeColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 12)]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Cairo',
                color: selected
                    ? (activeColor == AppColors.accent ? AppColors.bg : Colors.white)
                    : AppColors.text2,
              )),
        ),
      ),
    );
  }
}

// ── Numpad ────────────────────────────────────────────────────────────────────
class _Numpad extends StatelessWidget {
  final ValueChanged<String> onKey;
  final String type;
  final VoidCallback onSubmit;

  const _Numpad({required this.onKey, required this.type, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final keys = ['7','8','9','4','5','6','1','2','3','000','0','⌫'];
    final isExpense = type == 'expense';

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1.6,
            crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemCount: keys.length,
          itemBuilder: (_, i) {
            final k = keys[i];
            return GestureDetector(
              onTap: () => onKey(k),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: k == '⌫'
                    ? const Icon(Icons.backspace_outlined, color: AppColors.text2, size: 22)
                    : Text(k,
                        style: TextStyle(
                          fontSize: k == '000' ? 18 : 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                          fontFamily: 'monospace',
                        )),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onSubmit,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isExpense
                    ? [AppColors.red, const Color(0xFFCC2244)]
                    : [AppColors.accent, const Color(0xFF00BFFF)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (isExpense ? AppColors.red : AppColors.accent).withOpacity(0.3),
                  blurRadius: 16, offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              isExpense ? '✓  تسجيل المصروف' : '✓  تسجيل الدخل',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo',
                color: isExpense ? Colors.white : AppColors.bg,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
