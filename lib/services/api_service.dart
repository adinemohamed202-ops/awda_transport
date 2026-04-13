import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/user_session.dart';

class ApiService {
  static const String baseUrl =
      "https://backend-production-54e7.up.railway.app/api";

  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  /// ================= HEADERS =================
  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    String token = _token ?? "";

    if (token.isEmpty) {
      await UserSession.loadUser();
      token = UserSession.token;
    }

    return {
      if (withAuth && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  /// ================= REQUEST =================
  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body,
      {bool withAuth = true}) async {
    try {
      final headers = await _headers(withAuth: withAuth);

      final response = await http
          .post(
            Uri.parse("$baseUrl$endpoint"),
            headers: {
              "Content-Type": "application/json",
              ...headers,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل الاتصال");
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _headers();

      final response = await http
          .get(
            Uri.parse("$baseUrl$endpoint"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل الاتصال");
    }
  }

  /// ================= POST WITH FILE =================
  static Future<Map<String, dynamic>> postWithFile(
    String endpoint,
    Map<String, dynamic> fields, {
    File? file,
    String fileField = "file",
    bool withAuth = true,
  }) async {
    try {
      final request =
          http.MultipartRequest("POST", Uri.parse("$baseUrl$endpoint"));

      final headers = await _headers(withAuth: withAuth);
      request.headers.addAll(headers);

      fields.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, file.path),
        );
      }

      final res = await request.send();
      final response = await http.Response.fromStream(res);

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل رفع الملف");
    }
  }

  /// ================= DELETE =================
  static Future<Map<String, dynamic>> delete(
    String endpoint, [
    Map<String, dynamic>? body,
  ]) async {
    try {
      final headers = await _headers();

      final response = await http.delete(
        Uri.parse("$baseUrl$endpoint"),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return _error("فشل الحذف");
    }
  }

  /// ================= AUTH =================
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) {
    return post("/auth/register", {
      "username": username,
      "email": email,
      "password": password,
      "phone": phone,
    }, withAuth: false);
  }

  static Future<Map<String, dynamic>> login(
      String identifier, String password) async {
    final res = await post("/auth/login", {
      "username": identifier,
      "password": password,
    }, withAuth: false);

    /// 🔥 التعديل الصحيح هنا
    if (res["token"] != null) {
      setToken(res["token"]);

      if (res["user"] != null) {
        final userData = Map<String, dynamic>.from(res["user"]);
        userData["token"] = res["token"];

        await UserSession.saveUser(userData);
      }
    }

    return res;
  }

  /// ================= VERIFY =================
  static Future<Map<String, dynamic>> verifyCode(
      String email, String code) {
    return post("/auth/verify", {
      "email": email,
      "code": code,
    }, withAuth: false);
  }

  static Future<Map<String, dynamic>> resendCode(String email) {
    return post("/auth/resend", {
      "email": email,
    }, withAuth: false);
  }

  /// ================= WALLET =================
  static Future<Map<String, dynamic>> getWallet([String? uid]) {
    return get("/wallet");
  }

  static Future<Map<String, dynamic>> topUp(
      String uid, int amount) {
    return post("/wallet/topup", {
      "user_id": uid,
      "amount": amount,
    });
  }

  /// ================= COMPANY =================
  static String registerCompany() {
    return "$baseUrl/company/register";
  }

  static Future<Map<String, dynamic>> getCompanyTrips(String code) {
    return get("/company/trips?code=$code");
  }

  /// ================= TRIPS =================
  static Future<Map<String, dynamic>> getTrips(
      String type, String category) {
    return get("/trips?type=$type&category=$category");
  }

  static Future<Map<String, dynamic>> bookTrip({
    required String tripId,
    List<int>? seats,
    List<dynamic>? passengers,
  }) {
    return post("/trips/book", {
      "trip_id": tripId,
      "seats": seats ?? [],
      "passengers": passengers ?? [],
    });
  }

  /// ================= USER TRIPS =================
  static Future<Map<String, dynamic>> getUserTrips() {
    return get("/trips/user");
  }

  /// ================= USER BOOKINGS =================
  static Future<Map<String, dynamic>> getUserBookings() {
    return get("/bookings/user");
  }

  /// ================= TICKETS =================
  static Future<Map<String, dynamic>> getTickets() {
    return get("/tickets");
  }

  /// ================= CHAT =================
  static Future<Map<String, dynamic>> sendMessage({
    String? message,
    String? tripId,
    String? chatId,
  }) {
    return post("/chat/send", {
      "message": message,
      "trip_id": tripId,
      "chat_id": chatId,
    });
  }

  /// ================= RESPONSE =================
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return data;
      }

      return {
        "success": false,
        "message": data["message"] ?? "خطأ"
      };
    } catch (e) {
      return {"success": false, "message": "خطأ"};
    }
  }

  static Map<String, dynamic> _error(String msg) {
    return {"success": false, "message": msg};
  }
}