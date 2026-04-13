// file: company_dashboard_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class CompanyDashboardScreen extends StatefulWidget {
  final String companyCode;

  const CompanyDashboardScreen({super.key, required this.companyCode});

  @override
  State<CompanyDashboardScreen> createState() =>
      _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {

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
        Uri.parse(Api.getCompanyTrips(widget.companyCode)),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        trips = data["trips"];
      } else {
        showMsg("فشل في تحميل الرحلات");
      }

    } catch (e) {
      showMsg("خطأ في الاتصال بالسيرفر");
    }

    setState(() {
      isLoading = false;
    });
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم الشركة"),
      ),
      body: Column(
        children: [

          /// كود الشركة
          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  "كود الشركة: ${widget.companyCode}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.companyCode),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تم نسخ الكود"),
                      ),
                    );
                  },
                )

              ],
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "رحلات الشركة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : trips.isEmpty
                    ? const Center(child: Text("لا توجد رحلات بعد"))
                    : ListView.builder(
                        itemCount: trips.length,
                        itemBuilder: (context, index) {

                          var trip = trips[index];

                          DateTime tripDate = DateTime.parse(trip['date']);

                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              title: Text("${trip["from"]} ➜ ${trip["to"]}"),
                              subtitle: Text(
                                "التاريخ: ${tripDate.day}/${tripDate.month}/${tripDate.year}",
                              ),
                              trailing: Text(
                                "${trip["price"]} جنيه",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // فتح شاشة إضافة رحلة لاحقاً
                },
                child: const Text("إضافة رحلة"),
              ),
            ),
          )

        ],
      ),
    );
  }
}