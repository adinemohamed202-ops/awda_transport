import 'dart:io';
import '../models/ticket_model.dart';
import 'api_service.dart';
import '../utils/user_session.dart'; // 🔥 إضافة فقط

class TicketService {

  /// 📥 جلب كل التذاكر
  static Future<List<TicketModel>> getTickets(String userId) async {
    try {

      userId = userId.isEmpty ? (UserSession.userId ?? "") : userId; // 🔥 إضافة

      final response = await ApiService.postWithFile(
        "/tickets",
        {
          "user_id": userId,
        },
      );

      if (response["data"] == null) return [];

      List data = response["data"];

      return data.map<TicketModel>((e) {
        return TicketModel.fromJson(
          Map<String, dynamic>.from(e),
        );
      }).toList();

    } catch (e) {
      print("❌ getTickets error: $e");
      return [];
    }
  }

  /// 📤 إرسال تذكرة جديدة
  static Future<bool> createTicket(TicketModel ticket) async {
    try {
      final response = await ApiService.postWithFile(
        "/tickets/create",
        ticket.toJson(),
      );

      return response["success"] == true;

    } catch (e) {
      print("❌ createTicket error: $e");
      return false;
    }
  }

  /// ✅ تعليم التذكرة كمقروءة
  static Future<bool> markAsRead(String ticketId) async {
    try {
      final response = await ApiService.postWithFile(
        "/tickets/mark-read",
        {
          "ticket_id": ticketId,
        },
      );

      return response["success"] == true;

    } catch (e) {
      print("❌ markAsRead error: $e");
      return false;
    }
  }

  /// ✅ تعليم كل التذاكر كمقروءة
  static Future<bool> markAllAsRead(String userId) async {
    try {

      userId = userId.isEmpty ? (UserSession.userId ?? "") : userId; // 🔥 إضافة

      final response = await ApiService.postWithFile(
        "/tickets/mark-all-read",
        {
          "user_id": userId,
        },
      );

      return response["success"] == true;

    } catch (e) {
      print("❌ markAllAsRead error: $e");
      return false;
    }
  }

  /// 💰 طلب شحن
  static Future<bool> createDepositRequest({
    required int amount,
    required String userId,
    required String walletId,
    required String code,
    required File image,
  }) async {
    try {

      userId = userId.isEmpty ? (UserSession.userId ?? "") : userId; // 🔥 إضافة

      final response = await ApiService.postWithFile(
        "/deposits/create",
        {
          "amount": amount,
          "user_id": userId,
          "wallet_id": walletId,
          "code": code,
        },
        file: image,
      );

      return response["success"] == true;

    } catch (e) {
      print("❌ createDepositRequest error: $e");
      return false;
    }
  }

  /// 🚨 مشكلة في الإيداع
  static Future<bool> createDepositIssue({
    required String userId,
    required String walletId,
    required String code,
    required File image,
    String message = "مشكلة في الإيداع",
  }) async {
    try {

      userId = userId.isEmpty ? (UserSession.userId ?? "") : userId; // 🔥 إضافة

      final response = await ApiService.postWithFile(
        "/deposits/issue",
        {
          "user_id": userId,
          "wallet_id": walletId,
          "code": code,
          "message": message,
        },
        file: image,
      );

      return response["success"] == true;

    } catch (e) {
      print("❌ createDepositIssue error: $e");
      return false;
    }
  }

  /// ❌ حذف تذكرة
  static Future<bool> deleteTicket(String ticketId) async {
    try {
      final response = await ApiService.postWithFile(
        "/tickets/delete",
        {
          "ticket_id": ticketId,
        },
      );

      return response["success"] == true;

    } catch (e) {
      print("❌ deleteTicket error: $e");
      return false;
    }
  }

  /// ✅ قبول الإيداع (إضافة الرصيد)
  static Future<bool> approveDeposit({
    required String depositId,
  }) async {
    try {
      final response = await ApiService.postWithFile(
        "/admin/deposits/approve",
        {
          "deposit_id": depositId,
        },
      );

      return response["success"] == true;

    } catch (e) {
      print("❌ approveDeposit error: $e");
      return false;
    }
  }

  /// ❌ رفض الإيداع
  static Future<bool> rejectDeposit({
    required String depositId,
  }) async {
    try {
      final response = await ApiService.postWithFile(
        "/admin/deposits/reject",
        {
          "deposit_id": depositId,
        },
      );

      return response["success"] == true;

    } catch (e) {
      print("❌ rejectDeposit error: $e");
      return false;
    }
  }

  /// 📥 جلب كل طلبات الإيداع للأدمن
  static Future<List<TicketModel>> getAllDeposits() async {
    try {
      final response = await ApiService.postWithFile(
        "/admin/deposits",
        {},
      );

      if (response["data"] == null) return [];

      List data = response["data"];

      return data.map<TicketModel>((e) {
        return TicketModel.fromJson(
          Map<String, dynamic>.from(e),
        );
      }).toList();

    } catch (e) {
      print("❌ getAllDeposits error: $e");
      return [];
    }
  }
}