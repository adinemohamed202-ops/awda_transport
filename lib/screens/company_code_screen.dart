import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'company_supervisors_screen.dart';
import 'company_trips_screen.dart';

class CompanyCodeScreen extends StatefulWidget {
  final String companyCode;
  final String tripsCode;

  const CompanyCodeScreen({
    super.key,
    required this.companyCode,
    required this.tripsCode,
  });

  @override
  State<CompanyCodeScreen> createState() => _CompanyCodeScreenState();
}

class _CompanyCodeScreenState extends State<CompanyCodeScreen> {

  String companyCode = "";
  String tripsCode = "";

  bool loading = true;

  final String baseUrl = "http://192.168.1.3:3000/api";

  @override
  void initState() {
    super.initState();

    /// 🔥 نبدأ بالقيم الجاية من الشاشة السابقة
    companyCode = widget.companyCode;
    tripsCode = widget.tripsCode;

    /// 🔥 بعدين نحدثها من السيرفر
    fetchCodes();
  }

  /// ===========================
  /// 📥 جلب الأكواد من السيرفر
  /// ===========================
  Future<void> fetchCodes() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/company/codes/$companyCode"),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"]) {
        setState(() {
          companyCode = data["companyCode"];
          tripsCode = data["tripsCode"];
          loading = false;
        });
      } else {
        loading = false;
      }
    } catch (e) {
      loading = false;
    }
  }

  void copyCode(BuildContext context, String code, String message) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget buildCodeBox({
    required String title,
    required String code,
    required Color color,
    required String hint,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(hint,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectableText(
                code,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(Icons.copy, color: color),
                onPressed: () =>
                    copyCode(context, code, "تم نسخ الكود ✅"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> confirmExit(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("تأكيد الرجوع"),
            content: const Text("هل تريد الرجوع؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("لا"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("نعم"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () => confirmExit(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("أكواد الشركة"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              bool exit = await confirmExit(context);
              if (exit) Navigator.pop(context);
            },
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    buildCodeBox(
                      title: "كود الشركة",
                      code: companyCode,
                      color: Colors.blue,
                      hint: "أرسل هذا الكود للمشرفين لإضافة رحلات",
                      context: context,
                    ),

                    const SizedBox(height: 20),

                    buildCodeBox(
                      title: "كود الرحلات",
                      code: tripsCode,
                      color: Colors.green,
                      hint: "استخدم هذا الكود لعرض جميع الرحلات",
                      context: context,
                    ),

                    const SizedBox(height: 40),

                    /// 👥 المشرفين
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.people),
                        label: const Text("عرض المشرفين"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CompanySupervisorsScreen(
                                companyCode: companyCode,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// 🚌 الرحلات
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.directions_bus),
                        label: const Text("عرض الرحلات"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CompanyTripsScreen(
                                companyCode: companyCode,
                                tripsCode: tripsCode,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}