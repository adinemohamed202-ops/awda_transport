import '../services/api_service.dart'; // 🔥 إضافة فقط

class AppConstants {

  /// 💰 عمولة المقعد للشركة
  static int companyCommissionPerSeat = 2000;

  /// 💰 عمولة المقعد للمستخدم
  static int userCommissionPerSeat = 0;

  /// 🔥 تفعيل/إيقاف الخصم من الشركة
  static bool enableCompanyCommission = true;

  /// 🔥 تفعيل/إيقاف الخصم من المستخدم
  static bool enableUserCommission = false;

  /// 🌐 تحميل الإعدادات من السيرفر (إضافة فقط)
  static Future<void> loadFromApi() async {
    try {
      final response = await ApiService.get("/app-settings");

      if (response["success"] == true && response["data"] != null) {

        final data = response["data"];

        companyCommissionPerSeat =
            data["company_commission"] ?? companyCommissionPerSeat;

        userCommissionPerSeat =
            data["user_commission"] ?? userCommissionPerSeat;

        enableCompanyCommission =
            data["enable_company"] ?? enableCompanyCommission;

        enableUserCommission =
            data["enable_user"] ?? enableUserCommission;
      }

    } catch (e) {
      print("❌ AppConstants load error: $e");
    }
  }
}