import '../services/api_service.dart';
import '../utils/user_session.dart';

class WalletService {

  static int balance = 0;
  static List<Map<String, dynamic>> transactions = [];

  static Future<String?> _getUserId([String? passedId]) async {
    if (passedId != null && passedId.isNotEmpty) {
      return passedId;
    }

    if (UserSession.userId.isEmpty) {
      await UserSession.loadUser();
    }

    if (UserSession.userId.isEmpty) {
      print("❌ User ID is null");
      return null;
    }

    return UserSession.userId;
  }

  static Future<bool> loadWallet([String? userId]) async {
    try {
      final uid = await _getUserId(userId);
      if (uid == null) return false;

      final response = await ApiService.getWallet(uid);

      if (response["success"] == true && response["data"] != null) {
        final data = response["data"];

        balance = int.tryParse(data["balance"]?.toString() ?? "0") ?? 0;

        /// 🔥 إصلاح crash لو transactions مش List
        if (data["transactions"] != null && data["transactions"] is List) {
          transactions = List<Map<String, dynamic>>.from(
            (data["transactions"] as List)
                .map((e) => Map<String, dynamic>.from(e)),
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

  static Future<int> getBalance([String? userId]) async {
    final uid = await _getUserId(userId);
    if (uid == null) return 0;

    await loadWallet(uid);
    return balance;
  }

  static Future<bool> add({
    required String walletId,
    required int amount,
    required String title,
  }) async {
    if (amount <= 0) return false;

    try {
      final uid = await _getUserId(walletId); // 🔥 إصلاح
      if (uid == null) return false;

      final response = await ApiService.topUp(uid, amount);

      if (response["success"] == true) {
        await loadWallet(uid);

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

  static Future<bool> deduct({
    required int amount,
    String? userId,
  }) async {
    try {
      final uid = await _getUserId(userId);
      if (uid == null) return false;

      final response = await ApiService.topUp(uid, -amount);

      if (response["success"] == true) {
        await loadWallet(uid);

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

  static Stream<int> balanceStream(String walletId) async* {
    while (true) {
      try {
        await loadWallet(walletId);
        yield balance;
      } catch (e) {
        print("❌ balanceStream error: $e");
        yield balance;
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  static Stream<List<Map<String, dynamic>>> getTransactions(
      String walletId) async* {
    try {
      await loadWallet(walletId);
      yield transactions;
    } catch (e) {
      print("❌ getTransactions error: $e");
      yield [];
    }
  }
}