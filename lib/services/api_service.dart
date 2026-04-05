import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/user_session.dart';

class ApiService {

  static String baseUrl = "http://192.168.1.3:3000";

  static Future<Map<String, String>> _headers({bool isJson = true, bool withAuth = true}) async {
    String token = UserSession.token;

    if (token.isEmpty) {
      await UserSession.loadUser();
      token = UserSession.token;
    }

    return {
      if (isJson) "Content-Type": "application/json",
      if (withAuth && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static Future<http.Response> _safeRequest(
      Future<http.Response> Function() request) async {
    try {
      return await request().timeout(const Duration(seconds: 10));
    } catch (e) {
      print("⚠️ retrying request...");
      await Future.delayed(const Duration(seconds: 2));
      return await request().timeout(const Duration(seconds: 10));
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final headers = await _headers(withAuth: false);

      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/login"),
            headers: headers,
            body: jsonEncode({
              "email": email.trim(),
              "password": password.trim(),
            }),
          ));

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل الاتصال بالسيرفر");
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String phone, String email, String password) async {
    try {
      final headers = await _headers(withAuth: false);

      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/register"),
            headers: headers,
            body: jsonEncode({
              "name": name.trim(),
              "phone": phone.trim(),
              "email": email.trim(),
              "password": password.trim(),
            }),
          ));

      return _handleResponse(response);
    } catch (e) {
      return _error("مشكلة في الاتصال بالسيرفر");
    }
  }

  static Future<Map<String, dynamic>> verifyCode(
      String email, String code) async {
    try {
      final headers = await _headers(withAuth: false);

      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/verify"),
            headers: headers,
            body: jsonEncode({
              "email": email.trim(),
              "code": code.trim(),
            }),
          ));

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل التحقق من الكود");
    }
  }

  // ✅ تم التصحيح هنا فقط
  static Future<Map<String, dynamic>> resendCode(String email) async {
    try {
      final headers = await _headers(withAuth: false);

      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/resend"),
            headers: headers,
            body: jsonEncode({
              "email": email.trim(),
            }),
          ));

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل إعادة إرسال الكود");
    }
  }

  static Future<List<dynamic>> getTrips(
      String tripType, String? category) async {
    try {
      final uri = Uri.parse(
          "$baseUrl/trips?tripType=$tripType&category=${category ?? ""}");

      final headers = await _headers();

      final response =
          await _safeRequest(() => http.get(uri, headers: headers));

      if (response.body.isEmpty) return [];

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data is List) return data;
        if (data is Map && data["trips"] is List) return data["trips"];
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getWallet(String userId) async {
    try {
      final headers = await _headers();

      final response = await _safeRequest(() => http.get(
            Uri.parse("$baseUrl/wallet/$userId"),
            headers: headers,
          ));

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل تحميل المحفظة");
    }
  }

  static Future<Map<String, dynamic>> bookSeat({
    required String tripId,
    required String userId,
    required int seatNumber,
  }) async {
    try {
      final headers = await _headers();

      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/book"),
            headers: headers,
            body: jsonEncode({
              "tripId": tripId,
              "userId": userId,
              "seatNumber": seatNumber,
            }),
          ));

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل الحجز");
    }
  }

  static Future<Map<String, dynamic>> sendSupport({
    required String userId,
    required String message,
  }) async {
    try {
      final headers = await _headers();

      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/support"),
            headers: headers,
            body: jsonEncode({
              "userId": userId,
              "message": message.trim(),
            }),
          ));

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل إرسال المشكلة");
    }
  }

  static Future<Map<String, dynamic>> postWithFile(
    String endpoint,
    Map<String, dynamic> data, {
    File? file,
    String fileField = "file",
  }) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl$endpoint"),
      );

      final headers = await _headers(isJson: false);
      request.headers.addAll(headers);

      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (file != null && await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, file.path),
        );
      }

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 15));

      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل رفع الملف");
    }
  }

  static Future<Map<String, dynamic>> topUp(String userId, int amount) async {
    try {
      final headers = await _headers();
      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/wallet/top-up"),
            headers: headers,
            body: jsonEncode({"userId": userId, "amount": amount}),
          ));
      return _handleResponse(response);
    } catch (e) {
      return _error("فشل شحن المحفظة");
    }
  }

  static Future<List<dynamic>> getCompanyTrips(String companyId) async {
    try {
      final headers = await _headers();
      final response = await _safeRequest(() => http.get(
            Uri.parse("$baseUrl/company/$companyId/trips"),
            headers: headers,
          ));
      if (response.body.isEmpty) return [];
      final data = jsonDecode(response.body);
      if (data is List) return data;
      if (data is Map && data["trips"] is List) return data["trips"];
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> sendBookingRequest({
    required String tripId,
    required String userId,
    required int seatNumber,
  }) async {
    try {
      final headers = await _headers();
      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/booking/request"),
            headers: headers,
            body: jsonEncode({
              "tripId": tripId,
              "userId": userId,
              "seatNumber": seatNumber,
            }),
          ));
      return _handleResponse(response);
    } catch (e) {
      return _error("فشل إرسال طلب الحجز");
    }
  }

  static Future<Map<String, dynamic>> bookTrip({
    required String tripId,
    required List<int> seats,
    required List passengers,
  }) async {
    try {
      final headers = await _headers();

      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/booking/request"),
            headers: headers,
            body: jsonEncode({
              "tripId": tripId,
              "seats": seats,
              "passengers": passengers,
            }),
          ));

      final data = _handleResponse(response);

      if (!data.containsKey("bookingId")) {
        data["bookingId"] =
            DateTime.now().millisecondsSinceEpoch.toString();
      }

      return data;
    } catch (e) {
      return _error("فشل حجز الرحلة");
    }
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String tripId,
    required String message,
  }) async {
    try {
      final headers = await _headers();

      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/chat/send"),
            headers: headers,
            body: jsonEncode({
              "tripId": tripId,
              "message": message,
            }),
          ));

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل إرسال الرسالة");
    }
  }

  static Future<Map<String, dynamic>> deduct(
      String userId, double amount) async {
    try {
      final headers = await _headers();

      final response = await _safeRequest(() => http.post(
            Uri.parse("$baseUrl/wallet/deduct"),
            headers: headers,
            body: jsonEncode({
              "userId": userId,
              "amount": amount,
            }),
          ));

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل الخصم");
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return _error("الرد فاضي من السيرفر");
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 401) {
        UserSession.clear();
        return _error("انتهت الجلسة، سجل دخول من جديد");
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic>
            ? data
            : {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "message": data is Map && data.containsKey("message")
              ? data["message"]
              : "خطأ (${response.statusCode})"
        };
      }
    } catch (e) {
      return _error("خطأ في تحليل البيانات");
    }
  }

  static Map<String, dynamic> _error(String message) {
    return {
      "success": false,
      "message": message,
    };
  }
}