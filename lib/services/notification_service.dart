// file: lib/services/notification_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/user_session.dart';

class NotificationService {

  /// 🌐 Base API (تم التصحيح)
  static const String baseUrl =
      "https://backend-production-54e7.up.railway.app/api";

  /// 🔔 تهيئة الإشعارات
  static Future init() async {
    await sendDeviceInfo();
  }

  /// 📡 إرسال معلومات الجهاز للسيرفر
  static Future sendDeviceInfo() async {
    try {
      if (UserSession.userId == null ||
          UserSession.userId.toString().isEmpty) {
        print("⚠️ userId فارغ");
        return;
      }

      final response = await http
          .post(
            Uri.parse("$baseUrl/save-device"),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "user_id": UserSession.userId,
              "device": "flutter_app",
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("✅ تم تسجيل الجهاز بنجاح");
      } else {
        print("❌ السيرفر رد لكن في مشكلة: ${response.statusCode}");
      }

    } on TimeoutException {
      print("⏳ انتهى وقت الاتصال (timeout)");
    } catch (e) {
      print("❌ خطأ: $e");
    }
  }

  /// 📩 جلب الإشعارات
  static Future<List> getNotifications() async {
    try {
      if (UserSession.userId == null) return [];

      final response = await http
          .get(
            Uri.parse(
                "$baseUrl/notifications?user_id=${UserSession.userId}"),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } on TimeoutException {
      print("⏳ timeout في جلب الإشعارات");
      return [];
    } catch (e) {
      print("❌ error: $e");
      return [];
    }
  }
}