import '../services/api_service.dart';
import '../utils/user_session.dart';

class WalletService {

  static int balance = 0;
  static List<Map<String, dynamic>> transactions = [];

  /// 🔐 تأكد المستخدم
  static Future<String?> _getUserId() async {
    if (UserSession.userId.isEmpty) {
      await UserSession.loadUser();
    }

    if (UserSession.userId.isEmpty) {
      print("❌ User ID is null");
      return null;
    }

    return UserSession.userId;
  }

  /// 💰 تحميل المحفظة
  static Future<bool> loadWallet() async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      final response = await ApiService.getWallet(userId);

      if (response["success"] == true && response["data"] != null) {
        final data = response["data"];

        balance = int.tryParse(data["balance"]?.toString() ?? "0") ?? 0;

        if (data["transactions"] != null && data["transactions"] is List) {
          transactions = List<Map<String, dynamic>>.from(
            data["transactions"].map((e) => Map<String, dynamic>.from(e)),
          );
        } else {
          transactions = [];
        }

        return true;
      }

      return false;
    } catch (e) {
      print("❌ loadWallet error: $e");
      return false;
    }
  }

  /// 💰 جلب الرصيد
  static Future<int> getBalance(String walletId) async {
    await loadWallet();
    return balance;
  }

  /// ➕ شحن
  static Future<bool> add({
    required String walletId,
    required int amount,
    required String title,
  }) async {
    if (amount <= 0) return false;

    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      final response = await ApiService.topUp(userId, amount);

      if (response["success"] == true) {
        await loadWallet();

        transactions.insert(0, {
          "title": title,
          "amount": amount,
          "type": "credit",
          "date": DateTime.now().toString(),
        });

        return true;
      }

      return false;
    } catch (e) {
      print("❌ add error: $e");
      return false;
    }
  }

  /// ❌ خصم
  static Future<bool> deduct({
    required String userId,
    required double amount,
  }) async {
    try {
      // 🔥 مؤقتاً بنستخدم topUp لتفادي الخطأ (إلى حين إضافة API حقيقي للخصم)
      final response = await ApiService.topUp(userId, -amount.toInt());

      if (response["success"] == true) {
        await loadWallet();

        transactions.insert(0, {
          "title": "خصم",
          "amount": amount,
          "type": "debit",
          "date": DateTime.now().toString(),
        });

        return true;
      }

      return false;
    } catch (e) {
      print("❌ deduct error: $e");
      return false;
    }
  }

  /// 📡 بث الرصيد
  static Stream<int> balanceStream(String walletId) async* {
    while (true) {
      try {
        await loadWallet();
        yield balance;
      } catch (e) {
        print("❌ balanceStream error: $e");
        yield balance;
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  /// 📜 العمليات
  static Stream<List<Map<String, dynamic>>> getTransactions(
      String walletId) async* {
    try {
      await loadWallet();
      yield transactions;
    } catch (e) {
      print("❌ getTransactions error: $e");
      yield [];
    }
  }
}