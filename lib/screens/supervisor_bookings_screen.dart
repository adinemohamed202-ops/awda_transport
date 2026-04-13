import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'chat_screen.dart';

import '../services/api_service.dart';

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

class _SupervisorBookingsScreenState extends State<SupervisorBookingsScreen> {

  String loadingId = "";
  Set<String> seenIds = {};
  bool isFirstLoad = true;

  final AudioPlayer player = AudioPlayer();

  final Color primary = const Color(0xFF6C5CE7);
  final Color dark = const Color(0xFF0F172A);

  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  void onNewBooking() async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(AssetSource('sounds/notification.mp3'));
    Future.delayed(const Duration(seconds: 5), () => player.stop());
  }

  Future<void> fetchBookings() async {
    try {
      // ✅ تم تصحيح الاستدعاء (معامل واحد فقط)
      final response = await ApiService.get(
        "/booking_requests?companyCode=${widget.companyCode}&supervisorPhone=${widget.supervisorPhone}",
      );

      if (response == null) {
        showMsg("❌ فشل جلب الطلبات");
        return;
      }

      // ✅ تم تصحيح نوع البيانات
      final List data = response["data"] ?? [];

      if (!isFirstLoad) {
        for (var booking in data) {
          if (!seenIds.contains(booking["id"].toString())) {
            seenIds.add(booking["id"].toString());
            onNewBooking();
          }
        }
      } else {
        seenIds = data.map((e) => e["id"].toString()).toSet();
        isFirstLoad = false;
      }

      setState(() => bookings = List<Map<String, dynamic>>.from(data));

    } catch (e) {
      showMsg("❌ تأكد من الاتصال بالسيرفر");
    }
  }

  Future<void> acceptBooking(String id, Map booking) async {
    setState(() => loadingId = id);

    try {
      final response = await ApiService.post(
        "/booking_requests/accept",
        {
          "id": id,
        },
      );

      if (response == null || response["success"] == false) {
        showMsg("❌ خطأ في القبول");
      } else {
        showMsg("تم القبول ✅");
        fetchBookings();
      }

    } catch (e) {
      showMsg("❌ تأكد من الاتصال بالسيرفر");
    }

    setState(() => loadingId = "");
  }

  Future<void> rejectBooking(String id) async {
    setState(() => loadingId = id);

    try {
      final response = await ApiService.post(
        "/booking_requests/reject",
        {
          "id": id,
        },
      );

      if (response == null || response["success"] == false) {
        showMsg("❌ خطأ في الرفض");
      } else {
        showMsg("تم رفض الطلب ❌");
        fetchBookings();
      }

    } catch (e) {
      showMsg("❌ تأكد من الاتصال بالسيرفر");
    }

    setState(() => loadingId = "");
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildCard(Map<String, dynamic> booking) {
    String status = booking["status"] ?? "pending";
    String chatId = booking["chatId"] ?? "";
    bool isLoading = loadingId == booking["id"];

    String tripId = booking["tripId"]?.toString() ?? "";
    String bookingId = booking["id"]?.toString() ?? "";

    return Container(
      margin: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📌 الحالة: $status", style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                Text("💺 المقاعد: ${booking["seats"]}", style: const TextStyle(color: Colors.white70)),
                Text("💰 السعر: ${booking["price"]}", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 15),

                if (status == "pending")
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primary),
                          onPressed: isLoading ? null : () => acceptBooking(booking["id"], booking),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("قبول"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: isLoading ? null : () => rejectBooking(booking["id"]),
                          child: const Text("رفض"),
                        ),
                      ),
                    ],
                  ),

                if (status == "accepted")
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primary),
                    onPressed: chatId.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chatId,
                                  userType: "supervisor",
                                  tripId: tripId,
                                  bookingId: bookingId,
                                ),
                              ),
                            );
                          },
                    child: const Text("فتح الشات"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      appBar: AppBar(
        title: const Text("طلبات الحجز"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchBookings,
          )
        ],
      ),
      body: bookings.isEmpty
          ? const Center(child: Text("لا توجد طلبات", style: TextStyle(color: Colors.white)))
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) => buildCard(bookings[index]),
            ),
    );
  }
}