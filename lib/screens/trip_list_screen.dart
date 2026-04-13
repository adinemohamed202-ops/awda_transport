import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'seat_selection_screen.dart';

class TripListScreen extends StatefulWidget {
  final String tripType;
  final String? category;

  const TripListScreen({
    Key? key,
    required this.tripType,
    this.category,
  }) : super(key: key);

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  String fromSearch = "";
  String toSearch = "";
  bool isNavigating = false;

  List<Map<String, dynamic>> trips = [];
  bool isLoading = true;

  Future<void> refreshTrips() async {
    setState(() => isLoading = true);
    await loadTrips();
  }

  @override
  void initState() {
    super.initState();
    loadTrips();
  }

  Future loadTrips() async {
    try {
      final response =
          await ApiService.getTrips(widget.tripType, widget.category ?? ""); // ✅ الإصلاح هنا

      final data = response is Map ? response["data"] : response;

      if (!mounted) return;

      setState(() {
        if (data is List) {
          trips = List<Map<String, dynamic>>.from(
            data.map((e) {
              final trip = Map<String, dynamic>.from(e);

              trip["id"] ??= trip["tripId"];

              return trip;
            }),
          );
        } else {
          trips = [];
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ loadTrips error: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  int getRemainingSeats(Map<String, dynamic> trip) {
    int total = trip["totalSeats"] ?? trip["seats"] ?? 0;
    int booked = trip["bookedSeats"] ?? trip["booked"] ?? 0;
    return total - booked;
  }

  bool isTripExpired(String? tripDate) {
    if (tripDate == null) return true;

    try {
      return DateTime.parse(tripDate).isBefore(DateTime.now());
    } catch (e) {
      return true;
    }
  }

  String formatDate(String? date) {
    if (date == null) return "";
    try {
      final d = DateTime.parse(date);
      return "${d.year}-${d.month}-${d.day} | ${d.hour}:${d.minute}";
    } catch (e) {
      return "";
    }
  }

  void openSearch() {
    TextEditingController fromController = TextEditingController();
    TextEditingController toController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("بحث متقدم",
                  style: TextStyle(color: Colors.white)),
              SizedBox(height: 20),
              TextField(
                controller: fromController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "من",
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: toController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "إلى",
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    fromSearch = fromController.text.toLowerCase();
                    toSearch = toController.text.toLowerCase();
                  });
                  Navigator.pop(context);
                },
                child: Text("بحث"),
              )
            ],
          ),
        );
      },
    );
  }

  void navigateToSeats(Map<String, dynamic> trip) async {
    if (isNavigating) return;

    if (trip["id"] == null) {
      debugPrint("❌ trip id is null");
      return;
    }

    setState(() => isNavigating = true);

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeatSelectionScreen(
            trip: Map<String, dynamic>.from(trip),
            tripId: trip["id"].toString(),
          ),
        ),
      );

      await loadTrips();
    } catch (e) {
      debugPrint("Navigation error: $e");
    }

    if (!mounted) return;

    setState(() => isNavigating = false);
  }

  @override
  Widget build(BuildContext context) {
    var filtered = trips.where((trip) {
      if (isTripExpired(trip["tripDate"] ?? trip["date"])) return false;

      String from = (trip["from"] ?? "").toString().toLowerCase();
      String to = (trip["to"] ?? "").toString().toLowerCase();

      if (fromSearch.isNotEmpty && !from.contains(fromSearch)) return false;
      if (toSearch.isNotEmpty && !to.contains(toSearch)) return false;

      if (getRemainingSeats(trip) <= 0) return false;

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("الرحلات"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: openSearch,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0D0D), Color(0xFF1A0033)],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : filtered.isEmpty
                ? Center(
                    child: Text("🚫 لا توجد رحلات متاحة حالياً",
                        style: TextStyle(color: Colors.white)),
                  )
                : RefreshIndicator(
                    onRefresh: refreshTrips,
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        var trip = filtered[index];
                        int remaining = getRemainingSeats(trip);

                        return GestureDetector(
                          onTap: () => navigateToSeats(trip),
                          child: Container(
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.withOpacity(0.5),
                                        Colors.blueAccent.withOpacity(0.5),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (trip["companyName"] ?? "").toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "${trip["from"] ?? ""} ➜ ${trip["to"] ?? ""}",
                                        style:
                                            TextStyle(color: Colors.white70),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        formatDate(trip["tripDate"]),
                                        style:
                                            TextStyle(color: Colors.white54),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "💰 ${trip["price"] ?? 0}",
                                            style: TextStyle(
                                                color: Colors.white),
                                          ),
                                          Text(
                                            "🪑 $remaining",
                                            style: TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.deepPurple,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () =>
                                              navigateToSeats(trip),
                                          child: Text("احجز الآن"),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}