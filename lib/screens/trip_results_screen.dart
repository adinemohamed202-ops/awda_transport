import 'package:flutter/material.dart';
import 'seat_selection_screen.dart';
import '../data/trip_data.dart';

class TripResultsScreen extends StatelessWidget {
  final String from;
  final String to;
  final String transport;
  final String tripType;

  const TripResultsScreen({
    super.key,
    required this.from,
    required this.to,
    required this.transport,
    required this.tripType,
  });

  String clean(String text) => text.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String searchFrom = clean(from);
    String searchTo = clean(to);

    List<Map<String, dynamic>> filteredTrips = TripData.trips
        .cast<Map<String, dynamic>>()
        .where((trip) {

      DateTime tripDate = trip["tripDate"] is String
          ? DateTime.parse(trip["tripDate"])
          : trip["tripDate"];

      String tripFrom = clean(trip["from"]);
      String tripTo = clean(trip["to"]);
      String tripVehicle = trip["vehicle"].toString();

      /// 🔥 النظام القديم
      String tripTripType = trip["tripType"].toString();

      /// 🔥 النظام الجديد
      String type = trip["type"] ?? "";

      /// 🔥 التوافق بين القديم والجديد
      bool matchType =
          (type.isNotEmpty && type == tripType) ||
          (type.isEmpty &&
              (tripTripType == tripType || tripTripType.isEmpty));

      return tripDate.isAfter(now) &&
          matchType &&
          tripVehicle == transport &&
          tripFrom.contains(searchFrom) &&
          tripTo.contains(searchTo);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("الرحلات المتاحة")),
      body: filteredTrips.isEmpty
          ? const Center(
              child: Text(
                "لا توجد رحلات متاحة",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: filteredTrips.length,
              itemBuilder: (context, index) {
                var trip = filteredTrips[index];

                DateTime tripDate = trip["tripDate"] is String
                    ? DateTime.parse(trip["tripDate"])
                    : trip["tripDate"];

                int totalSeats = trip["totalSeats"] ?? 0;

                List<int> reservedSeats = [];
                if (trip["reservedSeats"] != null) {
                  reservedSeats = List<int>.from(trip["reservedSeats"]);
                }

                int bookedSeats = reservedSeats.length;
                int remainingSeats = totalSeats - bookedSeats;

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          trip["company"] ?? "غير محدد",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),

                        Text("${trip["from"]} ➜ ${trip["to"]}"),

                        const SizedBox(height: 6),

                        Text(
                          "التاريخ: ${tripDate.day}/${tripDate.month}/${tripDate.year}",
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "الوقت: ${tripDate.hour.toString().padLeft(2, '0')}:${tripDate.minute.toString().padLeft(2, '0')}",
                        ),

                        const SizedBox(height: 6),

                        Text("وسيلة النقل: ${trip["vehicle"]}"),

                        const SizedBox(height: 10),

                        Text("إجمالي المقاعد: $totalSeats"),

                        const SizedBox(height: 4),

                        Text(
                          "المقاعد المحجوزة: $bookedSeats",
                          style: const TextStyle(color: Colors.red),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "المقاعد المتبقية: $remainingSeats",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "سعر المقعد: ${trip["price"]} كريت",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: remainingSeats == 0
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SeatSelectionScreen(
                                          trip: trip,
                                          tripId: "local",
                                        ),
                                      ),
                                    );
                                  },
                            child: Text(
                              remainingSeats == 0
                                  ? "الرحلة مكتملة"
                                  : "احجز مقعد",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}