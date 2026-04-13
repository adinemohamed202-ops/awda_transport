import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'supervisor_bookings_screen.dart';

class SupervisorTripsScreen extends StatefulWidget {
  final String companyCode;
  final String supervisorPhone;

  const SupervisorTripsScreen({
    super.key,
    required this.companyCode,
    required this.supervisorPhone,
  });

  @override
  State<SupervisorTripsScreen> createState() =>
      _SupervisorTripsScreenState();
}

class _SupervisorTripsScreenState
    extends State<SupervisorTripsScreen> {

  late Future<List<dynamic>> tripsFuture;

  @override
  void initState() {
    super.initState();
    loadTrips();
  }

  void loadTrips() {
    // ✅ تم التصحيح هنا فقط
    tripsFuture = ApiService.getCompanyTrips(widget.companyCode).then((res) {
      return res["trips"] ?? res["data"] ?? [];
    });
  }

  /// 🔥 حل مشكلة اختلاف ID (مهم جداً)
  String getTripId(Map trip) {
    return trip["tripId"]?.toString() ??
           trip["_id"]?.toString() ??
           "";
  }

  /// 🗑️ حذف الرحلة
  Future<void> deleteTrip(String tripId) async {
    try {
      final res = await ApiService.postWithFile(
        "/delete-trip",
        {"tripId": tripId},
      );

      if (res["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حذف الرحلة ✅")),
        );
        setState(() => loadTrips());
      } else {
        throw Exception();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الحذف ❌")),
      );
    }
  }

  /// ✏️ تعديل الرحلة
  void editTrip(String tripId, Map trip, bool isFull) {

    if (isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن تعديل رحلة مكتملة")),
      );
      return;
    }

    TextEditingController priceController =
        TextEditingController(text: (trip["price"] ?? 0).toString());

    TextEditingController timeController =
        TextEditingController(text: trip["time"] ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تعديل الرحلة"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "السعر"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: "الوقت"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () async {

                final res = await ApiService.postWithFile(
                  "/update-trip",
                  {
                    "tripId": tripId,
                    "price": priceController.text,
                    "time": timeController.text,
                  },
                );

                Navigator.pop(context);

                if (res["success"] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم التعديل ✅")),
                  );
                  setState(() => loadTrips());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("فشل التعديل ❌")),
                  );
                }
              },
              child: const Text("حفظ"),
            ),
          ],
        );
      },
    );
  }

  /// ⚠️ تأكيد حذف
  void confirmDelete(String tripId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: const Text("هل أنت متأكد؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                deleteTrip(tripId);
              },
              child: const Text("حذف"),
            ),
          ],
        );
      },
    );
  }

  /// 📊 حساب المقاعد
  int bookedSeats(List seats) {
    return seats.where((s) => s["booked"] == true).length;
  }

  int totalSeats(List seats) {
    return seats.length;
  }

  bool isExpired(String date) {
    try {
      DateTime tripDate = DateTime.parse(date);
      DateTime nextDay = tripDate.add(const Duration(days: 1));
      return DateTime.now().isAfter(nextDay);
    } catch (e) {
      return false;
    }
  }

  bool isFull(List seats) {
    return bookedSeats(seats) >= totalSeats(seats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("رحلاتي"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: tripsFuture,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var trips = snapshot.data!;

          var activeTrips = trips.where((trip) {
            return !isExpired(trip["date"] ?? "");
          }).toList();

          if (activeTrips.isEmpty) {
            return const Center(child: Text("لا توجد رحلات نشطة"));
          }

          return ListView.builder(
            itemCount: activeTrips.length,
            itemBuilder: (context, index) {

              var trip = activeTrips[index];
              List seats = trip["seats"] ?? [];

              int booked = bookedSeats(seats);
              int total = totalSeats(seats);
              bool full = isFull(seats);

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "${trip["from"]} ➜ ${trip["to"]}",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text("🏢 ${trip["companyName"] ?? ""}"),
                      Text("👨‍✈️ ${trip["supervisorName"] ?? ""}"),

                      const SizedBox(height: 6),

                      Text("📅 ${trip["date"]}"),
                      Text("⏰ ${trip["time"]}"),
                      Text("💰 ${trip["price"]}"),
                      Text("🪑 $booked / $total"),

                      if (full)
                        const Text("مكتملة ❌",
                            style: TextStyle(color: Colors.red)),

                      const SizedBox(height: 10),

                      Row(
                        children: [

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SupervisorBookingsScreen(
                                      companyCode: widget.companyCode,
                                      supervisorPhone: widget.supervisorPhone,
                                    ),
                                  ),
                                );
                              },
                              child: const Text("الطلبات"),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange),
                              onPressed: () =>
                                  editTrip(getTripId(trip), trip, full),
                              child: const Text("تعديل"),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () =>
                                  confirmDelete(getTripId(trip)),
                              child: const Text("حذف"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}