# Flux — تطبيق إدارة المحفظة 💰

تطبيق Flutter احترافي لتتبع الدخل والمصروفات باللغة العربية.

---

## 🚀 طريقة التشغيل

### 1. المتطلبات
- Flutter SDK 3.0+ 
- Dart 3.0+
- Android Studio أو VS Code

### 2. تثبيت المكتبات
```bash
flutter pub get
```

### 3. تشغيل التطبيق
```bash
flutter run
```

### 4. بناء APK للأندرويد
```bash
flutter build apk --release
```
الملف يكون في: `build/app/outputs/flutter-apk/app-release.apk`

### 5. بناء للـ iOS
```bash
flutter build ios --release
```

---

## 📁 هيكل المشروع

```
lib/
├── main.dart                    # نقطة البداية
├── theme/
│   └── app_theme.dart           # الألوان والثيم
├── models/
│   ├── transaction_model.dart   # نموذج العملية
│   └── user_model.dart          # نموذج المستخدم
├── services/
│   ├── storage_service.dart     # التخزين والمصادقة
│   └── app_state.dart           # إدارة الحالة
└── screens/
    ├── splash_screen.dart       # شاشة البداية
    ├── login_screen.dart        # تسجيل الدخول / إنشاء حساب
    ├── main_screen.dart         # الشاشة الرئيسية + Nav
    ├── home_tab.dart            # تبويب الرئيسية
    ├── add_screen.dart          # إضافة عملية (Bottom Sheet)
    ├── history_tab.dart         # تبويب السجل
    ├── stats_tab.dart           # تبويب الإحصائيات
    └── profile_tab.dart         # تبويب الملف الشخصي
```

---

## 📦 المكتبات المستخدمة

| المكتبة | الغرض |
|---------|-------|
| `shared_preferences` | حفظ البيانات محلياً |
| `fl_chart` | الرسوم البيانية |
| `google_fonts` | خطوط Cairo و Syne |
| `provider` | إدارة الحالة |
| `crypto` | تشفير كلمة المرور |
| `uuid` | توليد معرفات فريدة |
| `intl` | تنسيق الأرقام والتواريخ |

---

## ✨ الميزات

- **Login / Register** مع تشفير SHA-256
- **4 تبويبات**: الرئيسية، السجل، الإحصائيات، الملف
- **12 فئة** للمصروفات والدخل
- **رسوم بيانية** (Bar Chart + Pie Chart)
- **بحث وفلتر** في السجل
- **متعدد المستخدمين** — كل مستخدم بياناته منفصلة
- **RTL عربي** كامل
- **ثيم داكن** احترافي (Flux Dark)
- **Haptic Feedback** عند الضغط

---

## 🎨 الثيم

| اللون | الكود |
|-------|-------|
| الخلفية | `#060B18` |
| Accent | `#10E8A0` |
| Red | `#FF4D6D` |
| Blue | `#4DA6FF` |
| Card | `#0F1A2E` |
"# budget-Tracker" 
