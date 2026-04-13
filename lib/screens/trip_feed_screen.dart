import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'seat_selection_screen.dart';

class TripListScreen extends StatefulWidget {
  final String tripType;

  const TripListScreen({
    super.key,
    required this.tripType,
  });

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {

  String search = "";
  List trips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  /// 🔥 جلب الرحلات
  Future<void> fetchTrips() async {
    try {

      final data = await ApiService.getTrips(widget.tripType);

      setState(() {
        trips = data;
        isLoading = false;
      });

    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  int getRemainingSeats(List seats) {
    int booked = seats.where((s) => s["booked"] == true).length;
    return seats.length - booked;
  }

  bool isTripExpired(String? tripDate) {
    if (tripDate == null) return false;
    DateTime d = DateTime.parse(tripDate);
    return d.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {

    var filtered = trips.where((trip) {

      if (!trip.containsKey("seats")) return false;

      if (isTripExpired(trip["tripDate"])) return false;

      String from = (trip["from"] ?? "").toLowerCase();
      String to = (trip["to"] ?? "").toLowerCase();

      if (!from.contains(search) && !to.contains(search)) {
        return false;
      }

      List seats = trip["seats"];
      if (getRemainingSeats(seats) == 0) return false;

      return true;

    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("الرحلات المتاحة"),
      ),

      body: Column(
        children: [

          /// 🔍 البحث
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "بحث (من / إلى)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text("لا توجد نتائج"))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {

                          var trip = filtered[index];

                          List seats = trip["seats"];
                          int remaining = getRemainingSeats(seats);

                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    trip["companyName"] ?? "",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    "${trip["from"]} ➜ ${trip["to"]}",
                                    style: const TextStyle(fontSize: 15),
                                  ),

                                  const SizedBox(height: 5),

                                  Text("📅 ${trip["tripDate"]}"),
                                  Text("🚍 ${trip["vehicle"] ?? ""}"),

                                  const SizedBox(height: 5),

                                  Text("💰 السعر: ${trip["price"]} كريت"),
                                  Text("المقاعد المتبقية: $remaining"),

                                  const SizedBox(height: 10),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SeatSelectionScreen(
                                              trip: trip,
                                              tripId: trip["id"],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text("احجز الآن"),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

        ],
      ),
    );
  }
}