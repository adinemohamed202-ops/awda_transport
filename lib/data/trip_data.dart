class TripData {

  static List<Map<String, dynamic>> trips = [];

  /// 🔥 إضافة رحلة (نسخة مطورة)
  static void addTrip(Map<String, dynamic> trip) {

    /// 🧠 لو ما في type → اعتبرها private
    if (!trip.containsKey("type")) {
      trip["type"] = "private";
    }

    /// 🧠 لو ما في companyCode
    if (!trip.containsKey("companyCode")) {
      trip["companyCode"] = "general";
    }

    /// 🧠 لو ما في tripCode
    if (!trip.containsKey("tripCode")) {
      trip["tripCode"] =
          "TRP-${DateTime.now().millisecondsSinceEpoch}";
    }

    /// 🧠 وقت الإنشاء
    trip["createdAt"] = DateTime.now();

    trips.add(trip);
  }

  /// 🔥 حذف الرحلات المنتهية
  static void removeExpiredTrips() {
    DateTime now = DateTime.now();

    trips.removeWhere((trip) {

      /// دعم القديم والجديد
      DateTime? tripDate;

      if (trip["tripDate"] != null) {
        tripDate = trip["tripDate"] is String
            ? DateTime.parse(trip["tripDate"])
            : trip["tripDate"];
      } else if (trip["date"] != null) {
        tripDate = trip["date"];
      }

      if (tripDate == null) return false;

      return now.isAfter(tripDate);
    });
  }
}