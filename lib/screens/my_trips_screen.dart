import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/user_session.dart';
import 'chat_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  List trips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:3000/bookings/${UserSession.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          trips = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching trips: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("رحلاتي"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trips.isEmpty
              ? const Center(child: Text("لا توجد حجوزات"))
              : ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    var data = trips[index];

                    List seats = data["seats"] ?? [];
                    String status = data["status"] ?? "pending";

                    String from = data["tripFrom"] ?? "غير معروف";
                    String to = data["tripTo"] ?? "غير معروف";
                    String company = data["companyName"] ?? "-";

                    /// 🔥 مهم: نحدد chatId
                    String chatId = data["chatId"]?.toString() ?? "";

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text("$from ➜ $to"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text("🏢 الشركة: $company"),
                            Text("💺 المقاعد: ${seats.join(", ")}"),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Text("الحالة: "),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        /// ✅ زر الشات بعد التعديل
                        trailing: ElevatedButton(
                          child: const Text("الشات"),
                          onPressed: () {
                            if (chatId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("لا يوجد شات لهذه الرحلة"),
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chatId,
                                  userType: "user", // 🔥 مهم
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}