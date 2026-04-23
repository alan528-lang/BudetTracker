import 'package:flutter/material.dart';
import 'package:flux_budget/screens/add_screen.dart';
import 'package:flux_budget/screens/statistics_page.dart';
import 'package:flux_budget/screens/transaction_history_screen.dart';
import 'profile_tab.dart';

class setting extends StatefulWidget {
  final Function(bool)? onThemeChanged;

  const setting({super.key, this.onThemeChanged});

  @override
  State<setting> createState() => _settingState();
}

class _settingState extends State<setting> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool autoUpdateEnabled = true;
  String selectedLanguage = 'English';

  // ── Theme Colors ─────────────────────────────────────────────
  static const Color _bgDark      = Color(0xFF060B18);   // primary background
  static const Color _accent      = Color(0xFF10E8A0);   // primary accent
  static const Color _red         = Color(0xFFFF4D6D);   // red accent
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
              child: const Icon(Icons.layers_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              "Settings",
              style: TextStyle(
                color: _textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          // Account Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Account",
              style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: _accent),
            title: const Text("Profile", style: TextStyle(color: _textPrimary)),
            subtitle: const Text("Manage your profile", style: TextStyle(color: _textMuted)),
            trailing: const Icon(Icons.arrow_forward, color: _textMuted),
            onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileTab()));},
          ),
          ListTile(
            leading: const Icon(Icons.description, color: _accent),
            title: const Text("add transaction", style: TextStyle(color: _textPrimary)),
            subtitle: const Text("add your money", style: TextStyle(color: _textMuted)),
            trailing: const Icon(Icons.arrow_forward, color: _textMuted),
            onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScreen()));},
          ),
          ListTile(
            leading: const Icon(Icons.history, color: _accent),
            title: const Text("Transactions history", style: TextStyle(color: _textPrimary)),
            subtitle: const Text("save your history", style: TextStyle(color: _textMuted)),
            trailing: const Icon(Icons.arrow_forward, color: _textMuted),
            onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()));},
          ),
          ListTile(
            leading: const Icon(Icons.poll, color: _accent),
            title: const Text("Reports Statistics", style: TextStyle(color: _textPrimary)),
            subtitle: const Text("report your expenses for the month", style: TextStyle(color: _textMuted)),
            trailing: const Icon(Icons.arrow_forward, color: _textMuted),
            onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsPage()));},
          ),
         const Divider(color: _border),
          // Notifications Section
         const  Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Notifications",
              style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: _accent),
            title: const Text("Enable Notifications", style: TextStyle(color: _textPrimary)),
            value: notificationsEnabled,
            activeColor: _accent,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          const Divider(color: _border),
          // Display Section
          const Padding(
            padding:  EdgeInsets.all(16.0),
            child: Text(
              "Display",
              style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: _accent),
            title: const Text("Dark Mode", style: TextStyle(color: _textPrimary)),
            value: darkModeEnabled,
            activeColor: _accent,
            onChanged: (bool value) {
              setState(() {
                darkModeEnabled = value;
              });
              widget.onThemeChanged?.call(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: _accent),
            title: const Text("Language", style: TextStyle(color: _textPrimary)),
            subtitle: Text(selectedLanguage, style: const TextStyle(color: _textMuted)),
            trailing: const Icon(Icons.arrow_forward, color: _textMuted),
            onTap: () {},
          ),
          const Divider(color: _border),
          // App Section
         const  Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "App",
              style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.cloud_download, color: _accent),
            title: const Text("Auto Update", style: TextStyle(color: _textPrimary)),
            value: autoUpdateEnabled,
            activeColor: _accent,
            onChanged: (bool value) {
              setState(() {
                autoUpdateEnabled = value;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: _accent),
            title: const Text("About", style: TextStyle(color: _textPrimary)),
            subtitle: const Text("Version 1.0.0", style: TextStyle(color: _textMuted)),
            trailing: const Icon(Icons.arrow_forward, color: _textMuted),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: _red),
            title: const Text("Logout", style: TextStyle(color: _red)),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}