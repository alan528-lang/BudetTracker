import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  int _months = 1;

  String _fmt(double n) {
    if (n.abs() >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M';
    if (n.abs() >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K';
    return n.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, state, __) {
        final txs = state.filtered(months: _months > 0 ? _months : null);
        final inc = txs.where((t) => t.isIncome).fold(0.0, (a, b) => a + b.amount);
        final exp = txs.where((t) => t.isExpense).fold(0.0, (a, b) => a + b.amount);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text('الإحصائيات',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
                      child: Text('نظرة شاملة على مالياتك',
                          style: TextStyle(fontSize: 13, color: AppColors.text2)),
                    ),

                    // Period tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _PTab(label: 'هذا الشهر', value: 1,  current: _months, onTap: (v) => setState(() => _months = v)),
                          _PTab(label: '3 أشهر',    value: 3,  current: _months, onTap: (v) => setState(() => _months = v)),
                          _PTab(label: '6 أشهر',    value: 6,  current: _months, onTap: (v) => setState(() => _months = v)),
                          _PTab(label: 'سنة',        value: 12, current: _months, onTap: (v) => setState(() => _months = v)),
                          _PTab(label: 'الكل',       value: 0,  current: _months, onTap: (v) => setState(() => _months = v)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Summary cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _SummaryCard(label: 'دخل',    value: _fmt(inc), color: AppColors.accent),
                          const SizedBox(width: 10),
                          _SummaryCard(label: 'مصروف',  value: _fmt(exp), color: AppColors.red),
                          const SizedBox(width: 10),
                          _SummaryCard(label: 'رصيد',   value: _fmt(inc - exp), color: AppColors.blue),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bar chart
                    _ChartCard(
                      title: 'الدخل والمصروفات الشهرية',
                      dotColor: AppColors.accent,
                      child: _BarChart(txs: txs),
                    ),
                    const SizedBox(height: 12),

                    // Donut chart
                    _ChartCard(
                      title: 'توزيع المصروفات',
                      dotColor: AppColors.red,
                      child: _DonutChart(txs: txs),
                    ),
                    const SizedBox(height: 16),

                    // Category breakdown
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('تفاصيل الفئات',
                          style: TextStyle(fontSize: 14, color: AppColors.text2,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 10),
                    _CatBreakdown(txs: txs),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }
}

// ── Period tab ────────────────────────────────────────────────────────────────
class _PTab extends StatelessWidget {
  final String label;
  final int value, current;
  final ValueChanged<int> onTap;

  const _PTab({required this.label, required this.value,
      required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accentBg : AppColors.card,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active ? AppColors.accent.withOpacity(0.35) : AppColors.border,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: active ? AppColors.accent : AppColors.text2, fontFamily: 'Cairo')),
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});

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

// ── Chart card ────────────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title;
  final Color dotColor;
  final Widget child;
  const _ChartCard({required this.title, required this.dotColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w700, color: AppColors.text2)),
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Bar chart ─────────────────────────────────────────────────────────────────
class _BarChart extends StatelessWidget {
  final List<dynamic> txs;
  const _BarChart({required this.txs});

  @override
  Widget build(BuildContext context) {
    // Build monthly groups
    final months = <String, Map<String, double>>{};
    for (final tx in txs) {
      final t = tx as dynamic;
      final d = t.date as DateTime;
      final k = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      months.putIfAbsent(k, () => {'inc': 0, 'exp': 0});
      if ((t.type as String) == 'income') {
        months[k]!['inc'] = (months[k]!['inc']! + (t.amount as double));
      } else {
        months[k]!['exp'] = (months[k]!['exp']! + (t.amount as double));
      }
    }

    final keys = months.keys.toList()..sort();
    final recent = keys.length > 6 ? keys.sublist(keys.length - 6) : keys;
    if (recent.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('لا توجد بيانات', style: TextStyle(color: AppColors.text2))),
      );
    }

    final maxVal = recent.fold<double>(0, (m, k) =>
        [m, months[k]!['inc']!, months[k]!['exp']!].reduce((a, b) => a > b ? a : b));

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxVal * 1.25,
          barGroups: recent.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: months[e.value]!['inc']!,
                  color: AppColors.accent,
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: months[e.value]!['exp']!,
                  color: AppColors.red,
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border2, strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= recent.length) return const SizedBox();
                  final parts = recent[idx].split('-');
                  const mNames = ['','يناير','فبراير','مارس','أبريل','مايو','يونيو',
                      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
                  return Text(
                    mNames[int.tryParse(parts[1]) ?? 1],
                    style: const TextStyle(fontSize: 10, color: AppColors.text2, fontFamily: 'Cairo'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Donut chart ───────────────────────────────────────────────────────────────
class _DonutChart extends StatelessWidget {
  final List<dynamic> txs;
  const _DonutChart({required this.txs});

  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (final tx in txs) {
      final t = tx as dynamic;
      if ((t.type as String) == 'expense') {
        totals[t.category as String] = (totals[t.category] ?? 0) + (t.amount as double);
      }
    }

    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    if (top.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('لا توجد مصروفات', style: TextStyle(color: AppColors.text2))),
      );
    }

    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 36,
                sections: top.map((e) {
                  final cat = getCat(e.key);
                  return PieChartSectionData(
                    color: Color(cat.color),
                    value: e.value,
                    showTitle: false,
                    radius: 40,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: top.map((e) {
              final cat = getCat(e.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                          color: Color(cat.color), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(cat.nameAr,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.text2, fontFamily: 'Cairo')),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Category breakdown ────────────────────────────────────────────────────────
class _CatBreakdown extends StatelessWidget {
  final List<dynamic> txs;
  const _CatBreakdown({required this.txs});

  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (final tx in txs) {
      final t = tx as dynamic;
      if ((t.type as String) == 'expense') {
        totals[t.category as String] = (totals[t.category] ?? 0) + (t.amount as double);
      }
    }
    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('لا توجد بيانات', style: TextStyle(color: AppColors.text2))),
      );
    }
    final max = sorted.first.value;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final e = sorted[i];
        final cat = getCat(e.key);
        final pct = max > 0 ? (e.value / max) : 0.0;
        return Row(
          children: [
            Text(cat.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat.nameAr,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${e.value.round()} IQD',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.text2, fontFamily: 'monospace')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: pct.toDouble(),
                      minHeight: 5,
                      backgroundColor: AppColors.bg3,
                      valueColor: AlwaysStoppedAnimation(Color(cat.color)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
