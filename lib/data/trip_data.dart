import 'trip_model.dart';

class TripData {
  // 🔥 قائمة الرحلات مخفية
  static final List<TripModel> _trips = [];

  /// 🔥 Getter آمن: يعطي نسخة غير قابلة للتعديل
  static List<TripModel> get trips => List.unmodifiable(_trips);

  /// 🔥 إضافة رحلة (نسخة احترافية مع copyWith)
  static void addTrip(TripModel trip) {
    final newTrip = trip.copyWith(
      type: trip.type ?? "private",
      companyCode: trip.companyCode ?? "general",
      tripCode: trip.tripCode ??
          "TRP-${DateTime.now().millisecondsSinceEpoch}",
      createdAt: trip.createdAt ?? DateTime.now(),
    );

    _trips.add(newTrip);
  }

  /// 🔥 حذف رحلة بواسطة الكود
  static void removeTrip(String tripCode) {
    _trips.removeWhere((t) => t.tripCode == tripCode);
  }

  /// 🔥 تنظيف الرحلات المنتهية
  static void removeExpiredTrips() {
    final now = DateTime.now();

    _trips.removeWhere((trip) {
      final tripDate = trip.tripDate;
      if (tripDate == null) return false;
      return now.isAfter(tripDate);
    });
  }

  /// 🔥 جلب الرحلات حسب الشركة
  static List<TripModel> getByCompany(String companyCode) {
    return _trips.where((t) => t.companyCode == companyCode).toList();
  }

  /// 🔥 جلب الرحلات حسب النوع (private / voluntary)
  static List<TripModel> getByType(String type) {
    return _trips.where((t) => t.type == type).toList();
  }

  /// 🔥 البحث بين الرحلات حسب نقطة البداية والنهاية
  static List<TripModel> search(String from, String to) {
    return _trips.where((t) {
      final matchFrom = t.from?.toLowerCase().contains(from.toLowerCase()) ?? false;
      final matchTo = t.to?.toLowerCase().contains(to.toLowerCase()) ?? false;
      return matchFrom && matchTo;
    }).toList();
  }

  /// 🔥 بحث متقدم: الشركة + النوع + التاريخ + من/إلى
  static List<TripModel> advancedSearch({
    String? companyCode,
    String? type,
    DateTime? date,
    String? from,
    String? to,
  }) {
    return _trips.where((t) {
      bool match = true;

      if (companyCode != null && t.companyCode != companyCode) match = false;
      if (type != null && t.type != type) match = false;
      if (date != null) {
        final tripDate = t.tripDate;
        if (tripDate == null ||
            tripDate.year != date.year ||
            tripDate.month != date.month ||
            tripDate.day != date.day) {
          match = false;
        }
      }
      if (from != null &&
          !(t.from?.toLowerCase().contains(from.toLowerCase()) ?? false)) {
        match = false;
      }
      if (to != null &&
          !(t.to?.toLowerCase().contains(to.toLowerCase()) ?? false)) {
        match = false;
      }

      return match;
    }).toList();
  }

  /// 🔥 مسح جميع الرحلات (مفيد للاختبار)
  static void clear() {
    _trips.clear();
  }
}