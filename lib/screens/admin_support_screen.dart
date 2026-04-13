import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {

  List requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/admin/support"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          requests = data["data"];
          loading = false;
        });
      } else {
        showMsg("فشل تحميل البيانات ❌");
        setState(() => loading = false);
      }
    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
      setState(() => loading = false);
    }
  }

  Future<void> updateStatus(String id, String status, Map item) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiService.baseUrl}/admin/support/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": status}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        showMsg("تم التحديث ✅");

        if (status == "accepted") {
          openChat(item);
        }

        fetchRequests();
      } else {
        showMsg("فشل التحديث ❌");
      }
    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
    }
  }

  void openChat(Map item) {
    showMsg("تم فتح الشات مع المستخدم");
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  LinearGradient getGradient(String status) {
    switch (status) {
      case "accepted":
        return const LinearGradient(colors: [Colors.green, Colors.greenAccent]);
      case "rejected":
        return const LinearGradient(colors: [Colors.red, Colors.redAccent]);
      default:
        return const LinearGradient(colors: [Colors.orange, Colors.deepOrange]);
    }
  }

  String getText(String status) {
    switch (status) {
      case "accepted":
        return "تم القبول";
      case "rejected":
        return "مرفوض";
      default:
        return "قيد الانتظار";
    }
  }

  IconData getIcon(String status) {
    switch (status) {
      case "accepted":
        return Icons.check_circle;
      case "rejected":
        return Icons.cancel;
      default:
        return Icons.hourglass_top;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("بلاغات الدعم"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text("لا توجد بلاغات"))
              : RefreshIndicator(
                  onRefresh: fetchRequests,
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final item = requests[index];
                      final status = item["status"] ?? "pending";

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: getGradient(status),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Row(
                                children: [
                                  Icon(getIcon(status),
                                      color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    getText(status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text("👤 ${item["name"] ?? ""}",
                                  style: const TextStyle(color: Colors.white)),
                              Text("📱 ${item["phone"] ?? ""}",
                                  style: const TextStyle(color: Colors.white)),
                              Text("💳 ${item["walletId"] ?? ""}",
                                  style: const TextStyle(color: Colors.white)),

                              const SizedBox(height: 10),

                              Text(
                                item["message"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 10),

                              if (status == "pending")
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.green.shade700,
                                        ),
                                        onPressed: () =>
                                            updateStatus(
                                                item["id"], "accepted", item),
                                        child: const Text("قبول"),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.red.shade700,
                                        ),
                                        onPressed: () =>
                                            updateStatus(
                                                item["id"], "rejected", item),
                                        child: const Text("رفض"),
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}