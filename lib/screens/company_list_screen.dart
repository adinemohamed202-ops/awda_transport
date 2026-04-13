import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {

  List companies = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  /// 🔥 جلب الشركات من API
  Future<void> fetchCompanies() async {

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {

      final res = await http.get(
        Uri.parse(ApiService.getCompanies()),
      );

      final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200 && data["success"] == true) {

        setState(() {
          companies = data["companies"] ?? [];
          isLoading = false;
        });

      } else {

        setState(() {
          isError = true;
          isLoading = false;
        });

        showMsg(data["message"] ?? "فشل تحميل البيانات ❌");

      }

    } catch (e) {

      setState(() {
        isError = true;
        isLoading = false;
      });

      showMsg("خطأ في الاتصال بالسيرفر ❌");

    }
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
        title: const Text("الشركات والمشتركين"),
        centerTitle: true,
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
                        onPressed: fetchCompanies,
                        child: const Text("إعادة المحاولة"),
                      )

                    ],
                  ),
                )

              : companies.isEmpty
                  ? const Center(child: Text("لا توجد بيانات"))

                  : RefreshIndicator(
                      onRefresh: fetchCompanies,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: companies.length,
                        itemBuilder: (context, index) {

                          final item = companies[index];

                          final name = item["name"] ?? "بدون اسم";
                          final type = item["type"] ?? "company";

                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(

                              leading: Icon(
                                type == "company"
                                    ? Icons.business
                                    : Icons.directions_car,
                                color: Colors.blue,
                              ),

                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Text(
                                type == "company"
                                    ? "شركة"
                                    : "مركبة",
                              ),

                              trailing: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}