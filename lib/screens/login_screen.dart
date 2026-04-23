import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // Login
  final _loginUserCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _loginPassHidden = true;
  String? _loginError;
  bool _loginLoading = false;

  // Register
  final _regNameCtrl = TextEditingController();
  final _regUserCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  bool _regPassHidden = true;
  String? _regNameErr, _regUserErr, _regPassErr;
  bool _regLoading = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {
          _loginError = null;
          _regNameErr = _regUserErr = _regPassErr = null;
        }));
  }

  @override
  void dispose() {
    _tab.dispose();
    _loginUserCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regUserCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    setState(() {
      _loginError = null;
      _loginLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    final ok = await StorageService.login(
      username: _loginUserCtrl.text.trim(),
      password: _loginPassCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loginLoading = false);
    if (ok) {
      _goMain();
    } else {
      setState(() => _loginError = 'اسم المستخدم أو كلمة المرور غير صحيحة');
    }
  }

  Future<void> _doRegister() async {
    setState(() {
      _regNameErr = _regUserErr = _regPassErr = null;
    });
    bool ok = true;
    if (_regNameCtrl.text.trim().length < 2) {
      setState(() => _regNameErr = 'الاسم مطلوب (حرفين على الأقل)');
      ok = false;
    }
    final u = _regUserCtrl.text.trim().toLowerCase();
    if (u.length < 3 || StorageService.userExists(u)) {
      setState(() => _regUserErr = 'اسم المستخدم مستخدم أو قصير جداً');
      ok = false;
    }
    if (_regPassCtrl.text.length < 6) {
      setState(() => _regPassErr = 'كلمة المرور قصيرة جداً (6 أحرف)');
      ok = false;
    }
    if (!ok) return;

    setState(() => _regLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    final success = await StorageService.register(
      username: u,
      name: _regNameCtrl.text.trim(),
      password: _regPassCtrl.text,
    );
    await StorageService.seedDemoData();
    if (!mounted) return;
    setState(() => _regLoading = false);
    if (success) _goMain();
  }

  void _goMain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const main_screen(),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Grid background
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          // Glow top
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accent.withOpacity(0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Brand
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, Color(0xFF0088FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.3),
                            blurRadius: 24,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Icon(Icons.layers_rounded,
                          color: AppColors.bg, size: 30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Flux',
                    style: GoogleFonts.syne(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تتبع مصاريفك بذكاء وسهولة',
                    style: TextStyle(fontSize: 14, color: AppColors.text2),
                  ),
                  const SizedBox(height: 32),

                  // Tab switcher
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tab,
                      indicator: BoxDecoration(
                        color: AppColors.card2,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.25)),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: AppColors.accent,
                      unselectedLabelColor: AppColors.text2,
                      labelStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                      tabs: const [
                        Tab(text: 'تسجيل الدخول'),
                        Tab(text: 'حساب جديد')
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: _tab.index == 0 ? 280 : 360,
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        _buildLoginForm(),
                        _buildRegisterForm(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Login form ────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Column(
      children: [
        _Field(
          label: 'اسم المستخدم',
          controller: _loginUserCtrl,
          hint: 'أدخل اسم المستخدم',
          icon: Icons.person_outline_rounded,
          keyboardType: TextInputType.text,
          hasError: _loginError != null,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'كلمة المرور',
          controller: _loginPassCtrl,
          hint: 'أدخل كلمة المرور',
          icon: Icons.lock_outline_rounded,
          obscure: _loginPassHidden,
          hasError: _loginError != null,
          suffix: IconButton(
            icon: Icon(
                _loginPassHidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.text3),
            onPressed: () =>
                setState(() => _loginPassHidden = !_loginPassHidden),
          ),
          onSubmit: _doLogin,
        ),
        if (_loginError != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.red, size: 14),
            const SizedBox(width: 6),
            Text(_loginError!,
                style: const TextStyle(color: AppColors.red, fontSize: 12)),
          ]),
        ],
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'تسجيل الدخول',
          loading: _loginLoading,
          color: AppColors.accent,
          textColor: AppColors.bg,
          onTap: _doLogin,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('لا يوجد لديك حساب؟ ',
                style: TextStyle(color: AppColors.text2, fontSize: 13)),
            GestureDetector(
              onTap: () => _tab.animateTo(1),
              child: const Text('إنشاء حساب',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }

  // ── Register form ─────────────────────────────────────────
  Widget _buildRegisterForm() {
    return Column(
      children: [
        _Field(
          label: 'الاسم الكامل',
          controller: _regNameCtrl,
          hint: 'مثال: أحمد علي',
          icon: Icons.badge_outlined,
          error: _regNameErr,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'اسم المستخدم',
          controller: _regUserCtrl,
          hint: 'اسم فريد للدخول',
          icon: Icons.alternate_email_rounded,
          error: _regUserErr,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'كلمة المرور',
          controller: _regPassCtrl,
          hint: '6 أحرف على الأقل',
          icon: Icons.lock_outline_rounded,
          obscure: _regPassHidden,
          error: _regPassErr,
          suffix: IconButton(
            icon: Icon(
                _regPassHidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.text3),
            onPressed: () => setState(() => _regPassHidden = !_regPassHidden),
          ),
          onSubmit: _doRegister,
        ),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'إنشاء الحساب',
          loading: _regLoading,
          color: AppColors.accent,
          textColor: AppColors.bg,
          onTap: _doRegister,
        ),
      ],
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final String? error;
  final bool hasError;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final VoidCallback? onSubmit;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.error,
    this.hasError = false,
    this.suffix,
    this.keyboardType,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.text2,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          onSubmitted: onSubmit != null ? (_) => onSubmit!() : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: suffix,
            errorText: error,
            errorStyle: const TextStyle(color: AppColors.red, fontSize: 11),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Text(label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontFamily: 'Cairo')),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withOpacity(0.04)
      ..strokeWidth = 0.5;
    const spacing = 44.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
