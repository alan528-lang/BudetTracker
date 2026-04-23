import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, state, __) {
        final user  = state.user;
        final txs   = state.transactions;
        final inc   = txs.where((t) => t.isIncome).fold(0.0, (a, b) => a + b.amount);
        final exp   = txs.where((t) => t.isExpense).fold(0.0, (a, b) => a + b.amount);

        String _fmt(double n) {
          if (n.abs() >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M';
          if (n.abs() >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K';
          return n.round().toString();
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Profile'),),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('الملف الشخصي',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                        ),
                      ),
          
                      // Profile hero
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [AppColors.accent, Color(0xFF0088FF)],
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                user?.initials ?? 'U',
                                style: const TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.bg),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user?.name ?? 'مستخدم',
                                      style: const TextStyle(
                                          fontSize: 20, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 3),
                                  Text('@${user?.username ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 13, color: AppColors.text2)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'عضو منذ ${user?.since.year ?? 2026}',
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.text3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
          
                      // Stats row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _StatCard(label: 'العمليات', value: txs.length.toString(), color: AppColors.text),
                            const SizedBox(width: 10),
                            _StatCard(label: 'دخل',    value: _fmt(inc), color: AppColors.accent),
                            const SizedBox(width: 10),
                            _StatCard(label: 'مصروف',  value: _fmt(exp), color: AppColors.red),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
          
                      // Settings
                      _SettingsSection(
                        items: [
                          // _SettingItem(emoji: '🔔', title: 'الإشعارات', sub: 'إدارة التنبيهات'),
                         const _SettingItem(emoji: '🌍', title: 'العملة', sub: ' جنيه مصري — EG'),
                         const _SettingItem(emoji: '🔒', title: 'تغيير كلمة المرور', sub: 'تحديث بيانات الدخول'),
                          _SettingItem(
                            emoji: '🗑️',
                            title: 'حذف كل البيانات',
                            sub: 'إعادة ضبط التطبيق',
                            danger: true,
                            onTap: () => _confirmClear(context, state),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
          
                      // Logout
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () => _logout(context, state),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: AppColors.redBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.red.withOpacity(0.2)),
                            ),
                            alignment: Alignment.center,
                            child: const Text('تسجيل الخروج',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700,
                                    color: AppColors.red, fontFamily: 'Cairo')),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('Flux v2.0 — تطبيق إدارة المحفظة',
                            style: TextStyle(fontSize: 11, color: AppColors.text3)),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  void _logout(BuildContext ctx, AppState state) async {
    await StorageService.logout();
    state.clearUser();
    if (!ctx.mounted) return;
    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _confirmClear(BuildContext ctx, AppState state) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('حذف جميع البيانات؟',
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
              state.clearAll();
            },
            child: const Text('حذف',
                style: TextStyle(color: AppColors.red, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppColors.text2,
                    fontWeight: FontWeight.w700, letterSpacing: 0.4)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: color, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final List<_SettingItem> items;
  const _SettingsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return _SettingRow(item: e.value, isLast: isLast);
        }).toList(),
      ),
    );
  }
}

class _SettingItem {
  final String emoji, title, sub;
  final bool danger;
  final VoidCallback? onTap;
  const _SettingItem({
    required this.emoji, required this.title, required this.sub,
    this.danger = false, this.onTap,
  });
}

class _SettingRow extends StatelessWidget {
  final _SettingItem item;
  final bool isLast;
  const _SettingRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: item.danger ? AppColors.redBg : AppColors.accentBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: item.danger ? AppColors.red : AppColors.text)),
                      Text(item.sub,
                          style: const TextStyle(fontSize: 12, color: AppColors.text2)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left_rounded, color: AppColors.text3, size: 20),
              ],
            ),
          ),
          if (!isLast)
            const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
        ],
      ),
    );
  }
}
