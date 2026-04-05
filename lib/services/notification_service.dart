// file: lib/services/notification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/user_session.dart';

class NotificationService {

  /// 🔔 تهيئة الإشعارات (API فقط)
  static Future init() async {
    await sendDeviceInfo();
  }

  /// 📡 إرسال معلومات الجهاز للسيرفر (بدل FCM)
  static Future sendDeviceInfo() async {
    try {
      if (UserSession.userId == null) {
        print("⚠️ userId فارغ");
        return;
      }

      final response = await http.post(
        Uri.parse("https://your-api.com/save-device"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": UserSession.userId,
          "device": "flutter_app",
        }),
      );

      if (response.statusCode == 200) {
        print("✅ تم تسجيل الجهاز بنجاح");
      } else {
        print("❌ فشل تسجيل الجهاز");
      }

    } catch (e) {
      print("❌ خطأ: $e");
    }
  }

  /// 📩 جلب الإشعارات من السيرفر
  static Future<List> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://your-api.com/notifications?user_id=${UserSession.userId}"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print("❌ error: $e");
      return [];
    }
  }
}