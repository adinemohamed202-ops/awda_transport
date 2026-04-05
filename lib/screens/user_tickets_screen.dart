import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserTicketsScreen extends StatefulWidget {
  final String userPhone;

  const UserTicketsScreen({super.key, required this.userPhone});

  @override
  State<UserTicketsScreen> createState() => _UserTicketsScreenState();
}

class _UserTicketsScreenState extends State<UserTicketsScreen> {

  List tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  /// 🔥 جلب التذاكر من السيرفر
  Future<void> fetchTickets() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:3000/tickets/${widget.userPhone}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          tickets = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }

    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("تذاكري 🎫"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
              ? const Center(child: Text("لا توجد تذاكر"))
              : ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {

                    var ticket = tickets[index];

                    return Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              ticket["companyName"] ?? "",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text("👤 ${ticket["passengerName"]}"),

                            const Divider(),

                            Text("📍 ${ticket["from"]} ➜ ${ticket["to"]}"),

                            const SizedBox(height: 5),

                            Text("📅 ${ticket["date"]}"),
                            Text("⏰ ${ticket["time"]}"),
                            Text("🪑 مقعد: ${ticket["seat"]}"),

                            const SizedBox(height: 10),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              color: Colors.black,
                              child: Text(
                                ticket["qrCode"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "اعرض هذا الكود عند الصعود",
                              style: TextStyle(color: Colors.grey),
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