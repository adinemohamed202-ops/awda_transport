import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class SupervisorBookingsScreen extends StatefulWidget {
  final String companyCode;
  final String supervisorPhone;

  const SupervisorBookingsScreen({
    super.key,
    required this.companyCode,
    required this.supervisorPhone,
  });

  @override
  State<SupervisorBookingsScreen> createState() =>
      _SupervisorBookingsScreenState();
}

class _SupervisorBookingsScreenState
    extends State<SupervisorBookingsScreen> {

  List bookings = [];
  bool isLoading = true;
  String loadingId = "";

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  /// 🔥 جلب الطلبات
  Future<void> fetchBookings() async {
    try {

      final data = await ApiService.getSupervisorBookings(
        widget.companyCode,
        widget.supervisorPhone,
      );

      setState(() {
        bookings = data;
        isLoading = false;
      });

    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /// ✅ قبول
  Future<void> acceptBooking(String id) async {
    setState(() => loadingId = id);

    try {

      final res = await ApiService.acceptBooking(id);

      if (res["success"] == true) {
        showMsg("تم القبول ✅");
        fetchBookings();
      } else {
        showMsg(res["message"] ?? "فشل ❌");
      }

    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
    }

    setState(() => loadingId = "");
  }

  /// ❌ رفض
  Future<void> rejectBooking(String id) async {
    setState(() => loadingId = id);

    try {

      final res = await ApiService.rejectBooking(id);

      if (res["success"] == true) {
        showMsg("تم الرفض ❌");
        fetchBookings();
      } else {
        showMsg(res["message"] ?? "فشك ❌");
      }

    } catch (e) {
      showMsg("خطأ ❌");
    }

    setState(() => loadingId = "");
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case "accepted":
        return "تم القبول";
      case "rejected":
        return "تم الرفض";
      default:
        return "قيد الانتظار";
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("طلبات الحجز"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text("لا توجد طلبات"))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {

                    var booking = bookings[index];

                    String status = booking["status"] ?? "pending";
                    List seats = booking["seats"] ?? [];
                    List passengers = booking["passengers"] ?? [];
                    String chatId = booking["chatId"] ?? "";

                    bool isBtnLoading = loadingId == booking["id"];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              passengers.isNotEmpty
                                  ? passengers[0]["name"]
                                  : "بدون اسم",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text("المقاعد: ${seats.join(", ")}"),

                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: getStatusColor(status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                getStatusText(status),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [

                                if (status == "pending") ...[
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      onPressed: isBtnLoading
                                          ? null
                                          : () => acceptBooking(booking["id"]),
                                      child: isBtnLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white)
                                          : const Text("قبول"),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: isBtnLoading
                                          ? null
                                          : () => rejectBooking(booking["id"]),
                                      child: const Text("رفض"),
                                    ),
                                  ),
                                ],

                                if (status == "accepted") ...[
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: chatId.isEmpty
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ChatScreen(
                                                    chatId: chatId,
                                                    userType: "supervisor",
                                                  ),
                                                ),
                                              );
                                            },
                                      child: const Text("فتح الشات"),
                                    ),
                                  ),
                                ],

                              ],
                            )

                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}