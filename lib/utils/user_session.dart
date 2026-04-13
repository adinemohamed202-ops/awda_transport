import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class UserSession {

  static String userId = "";
  static String username = "";
  static String email = "";
  static String walletId = "";
  static double balance = 0;

  static String get uid => userId;
  static String get wallet => walletId;
  static String get name => username;

  static String token = "";

  static bool get isLoggedIn => userId.isNotEmpty;

  static bool _isLoaded = false;

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

    ApiService.setToken(token);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("userId", userId);
    await prefs.setString("username", username);
    await prefs.setString("email", email);
    await prefs.setString("walletId", walletId);
    await prefs.setDouble("balance", balance);
    await prefs.setString("token", token);

    _isLoaded = true;
  }

  /// 🔥 تحسين مهم: دعم كل أشكال البيانات من السيرفر
  static Future<void> saveUser(Map<String, dynamic> data) async {

    userId = (
      data["id"] ??
      data["user_id"] ??
      data["_id"] ??
      ""
    ).toString();

    username = (
      data["name"] ??
      data["username"] ??
      ""
    ).toString();

    email = data["email"]?.toString() ?? "";

    walletId = (
      data["walletId"] ??
      data["wallet_id"] ??
      ""
    ).toString();

    final rawBalance = data["balance"];
    if (rawBalance is int) {
      balance = rawBalance.toDouble();
    } else if (rawBalance is double) {
      balance = rawBalance;
    } else {
      balance = double.tryParse(rawBalance?.toString() ?? "0") ?? 0;
    }

    token = (
      data["token"] ??
      data["access_token"] ??
      ""
    ).toString();

    ApiService.setToken(token);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("userId", userId);
    await prefs.setString("username", username);
    await prefs.setString("email", email);
    await prefs.setString("walletId", walletId);
    await prefs.setDouble("balance", balance);
    await prefs.setString("token", token);

    _isLoaded = true;
  }

  static Map<String, dynamic> get user => {
    "id": userId,
    "name": username,
    "email": email,
    "wallet_id": walletId,
    "balance": balance,
  };

  static Future<void> loadUser() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getString("userId") ?? "";
    username = prefs.getString("username") ?? "";
    email = prefs.getString("email") ?? "";
    walletId = prefs.getString("walletId") ?? "";
    balance = prefs.getDouble("balance") ?? 0;
    token = prefs.getString("token") ?? "";

    if (token.isNotEmpty) {
      ApiService.setToken(token);
    }

    _isLoaded = true;
  }

  static Future<String?> safeUserId() async {
    if (userId.isEmpty) {
      await loadUser();
    }

    if (userId.isEmpty) {
      return null;
    }

    return userId;
  }

  static Future<void> updateBalance(double newBalance) async {
    balance = newBalance;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("balance", newBalance);
  }

  static Future<void> updateToken(String newToken) async {
    token = newToken;

    ApiService.setToken(newToken);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", newToken);
  }

  static Future<void> syncWithServer() async {
    try {
      final uid = await safeUserId();
      if (uid == null) return;

      final response = await ApiService.get("/user/profile?user_id=$uid");

      if (response["success"] == true && response["data"] != null) {
        final data = response["data"];

        username = data["name"]?.toString() ?? username;
        email = data["email"]?.toString() ?? email;
        walletId = data["wallet_id"]?.toString() ?? walletId;

        final bal = data["balance"];
        if (bal != null) {
          balance = double.tryParse(bal.toString()) ?? balance;
        }

        // ✅ حفظ التحديث
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("username", username);
        await prefs.setString("email", email);
        await prefs.setString("walletId", walletId);
        await prefs.setDouble("balance", balance);
      }

    } catch (e) {}
  }

  static Future<void> clear() async {
    userId = "";
    username = "";
    email = "";
    walletId = "";
    balance = 0;
    token = "";
    _isLoaded = false;

    ApiService.setToken("");

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}