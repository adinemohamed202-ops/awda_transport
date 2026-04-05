import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DepositNotificationsScreen extends StatefulWidget {
  const DepositNotificationsScreen({super.key});

  @override
  State<DepositNotificationsScreen> createState() =>
      _DepositNotificationsScreenState();
}

class _DepositNotificationsScreenState
    extends State<DepositNotificationsScreen> {

  List requests = [];
  bool isLoading = true;
  bool isError = false;

  final String baseUrl = "http://192.168.1.3:3000/api";

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  /// 🔥 جلب إشعارات الإيداع
  Future<void> fetchRequests() async {

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {

      final res = await http.get(
        Uri.parse("$baseUrl/topup-requests"),
      );

      final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200 && data["success"] == true) {

        setState(() {
          requests = data["requests"] ?? [];
          isLoading = false;
        });

      } else {

        setState(() {
          isError = true;
          isLoading = false;
        });

      }

    } catch (e) {

      setState(() {
        isError = true;
        isLoading = false;
      });

      showMsg("خطأ في الاتصال ❌");

    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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

  String getStatusText(String status) {
    switch (status) {
      case "approved":
        return "مقبول";
      case "rejected":
        return "مرفوض";
      default:
        return "قيد المراجعة";
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("إشعارات الإيداع"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text("حدث خطأ ❌"),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: fetchRequests,
                        child: const Text("إعادة المحاولة"),
                      )

                    ],
                  ),
                )

              : requests.isEmpty
                  ? const Center(child: Text("لا توجد إشعارات"))

                  : RefreshIndicator(
                      onRefresh: fetchRequests,
                      child: ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, i) {

                          final item = requests[i];

                          final amount = item["amount"] ?? 0;
                          final walletId = item["walletId"] ?? "-";
                          final userId = item["userId"] ?? "-";
                          final status = item["status"] ?? "pending";

                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(

                              leading: CircleAvatar(
                                backgroundColor:
                                    getStatusColor(status),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                ),
                              ),

                              title: Text(
                                "المبلغ: $amount",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  const SizedBox(height: 5),
                                  Text("Wallet: $walletId"),
                                  Text("User: $userId"),

                                  const SizedBox(height: 5),

                                  Text(
                                    "الحالة: ${getStatusText(status)}",
                                    style: TextStyle(
                                      color:
                                          getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

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