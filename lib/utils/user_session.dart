import 'package:shared_preferences/shared_preferences.dart';

class UserSession {

  /// 🔥 بيانات المستخدم
  static String userId = "";
  static String username = "";
  static String email = "";
  static String walletId = "";
  static double balance = 0;

  /// ✅ 🔥 حل المشكلة هنا (إضافة aliases)
  static String get uid => userId;
  static String get wallet => walletId;

  /// 🧑‍💻 إضافة Getter للـ name لاستخدامه في الـ home_screen
  static String get name => username;

  /// 🔐 مهم جداً للـ API
  static String token = "";

  /// 🧠 حالة تسجيل الدخول
  static bool get isLoggedIn => userId.isNotEmpty;

  /// ✅ تحميل البيانات مرة واحدة فقط
  static bool _isLoaded = false;

  /// 📥 حفظ البيانات + تخزين دائم
  static Future<void> setUser({
    required String uid,
    required String name,
    required String userEmail,
    required String wallet,
    double userBalance = 0,
    String userToken = "",
  }) async {

    userId = uid.toString();
    username = name;
    email = userEmail;
    walletId = wallet.toString();
    balance = userBalance;
    token = userToken;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("userId", userId);
    await prefs.setString("username", username);
    await prefs.setString("email", email);
    await prefs.setString("walletId", walletId);
    await prefs.setDouble("balance", balance);
    await prefs.setString("token", token);

    _isLoaded = true;
  }

  /// 🔄 تحميل البيانات عند فتح التطبيق (مرة واحدة فقط)
  static Future<void> loadUser() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getString("userId") ?? "";
    username = prefs.getString("username") ?? "";
    email = prefs.getString("email") ?? "";
    walletId = prefs.getString("walletId") ?? "";
    balance = prefs.getDouble("balance") ?? 0;
    token = prefs.getString("token") ?? "";

    _isLoaded = true;
  }

  /// 🔥 استخدام آمن لـ userId
  static Future<String?> safeUserId() async {
    if (userId.isEmpty) {
      await loadUser();
    }

    if (userId.isEmpty) {
      print("❌ safeUserId: userId is still empty");
      return null;
    }

    return userId;
  }

  /// 💰 تحديث الرصيد
  static Future<void> updateBalance(double newBalance) async {
    balance = newBalance;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("balance", newBalance);
  }

  /// 🔐 تحديث التوكن
  static Future<void> updateToken(String newToken) async {
    token = newToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", newToken);
  }

  /// 🧹 تسجيل خروج
  static Future<void> clear() async {
    userId = "";
    username = "";
    email = "";
    walletId = "";
    balance = 0;
    token = "";
    _isLoaded = false;

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}