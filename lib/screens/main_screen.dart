import 'package:flutter/material.dart';
import '../screens/setting.dart';

class main_screen extends StatefulWidget {
  const main_screen({super.key});

  @override
  State<main_screen> createState() => _homepageState();
}

class _homepageState extends State<main_screen> {
  int _selectedIndex = 0;

  // ── Theme Colors ─────────────────────────────────────────────
  static const Color _bgDark      = Color(0xFF060B18);   // primary background
  static const Color _bgCard      = Color(0xFF0F1A2E);   // card surface
  static const Color _bgCardAlt   = Color(0xFF16243D);   // alt card
  static const Color _teal        = Color(0xFF10E8A0);   // primary accent
  static const Color _green       = Color(0xFF10E8A0);   // bright green (CTA)
  static const Color _textPrimary = Color(0xFFEEF2FF);   // primary text
  static const Color _textMuted   = Color(0xFF6B7FA3);   // muted text
  static const Color _border      = Color(0x0FFFFFFF);   // subtle border

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        foregroundColor: _textPrimary,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.layers_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              "Dashboard",
              style: TextStyle(
                color: _textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const setting()),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: _textMuted),
          ),
        ],
      ),

      body: _selectedIndex == 0 ? _buildHome() : _buildHome(),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_teal, _green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _teal.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => setState(() => _selectedIndex = 1),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // ── Main Home Page ────────────────────────────────────────────
  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Balance Card ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: _teal.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Total Balance",
                      style: TextStyle(color: _textMuted, fontSize: 13, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // income
                const Text(
                  "\$3,769.26",
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      "April 2026",
                      style: TextStyle(color: _textMuted, fontSize: 13),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _green.withOpacity(0.3)),
                      ),
                      child: const Text(
                        "+2.4%",
                        style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Income / Expenses Row ─────────────────────────────
          Row(
            children: [
              Expanded(child: _statCard("Income", "\$111", Icons.arrow_downward_rounded, _teal)),
              const SizedBox(width: 12),
              Expanded(child: _statCard("Expenses", "\$180.74", Icons.arrow_upward_rounded, const Color(0xFFFF4D6D))),
            ],
          ),

          const SizedBox(height: 28),

          // ── Section Header ────────────────────────────────────
          Row(
            children: [
              const Text(
                "Recent Transactions",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                "See all",
                style: TextStyle(fontSize: 13, color: _teal),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Transactions ──────────────────────────────────────
          _transactionTile(Icons.shopping_basket_outlined, "Grocery Run",   "Food",          "-\$87.45",    const Color(0xFFFC4C56)),
          _transactionTile(Icons.play_circle_outline,      "Netflix",        "Entertainment", "-\$15.99",    const Color(0xFFFF4D6D)),
          _transactionTile(Icons.directions_car_outlined,  "Uber",           "Transport",     "-\$12.30",    _teal),
          _transactionTile(Icons.account_balance_wallet_outlined, "Salary",  "Income",        "+\$3,500.00", _green),
        ],
      ),
    );
  }

  // ── Stat Card (Income / Expense) ─────────────────────────────
  Widget _statCard(String label, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: _textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  // ── Transaction Tile ─────────────────────────────────────────
  Widget _transactionTile(IconData icon, String title, String category, String amount, Color color) {
    final bool isIncome = amount.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.25), width: 1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  category,
                  style: const TextStyle(color: _textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isIncome ? _green : const Color(0xFFFF4D6D),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}