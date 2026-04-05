import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompanySupervisorsScreen extends StatefulWidget {
  final String companyCode;

  const CompanySupervisorsScreen({
    super.key,
    required this.companyCode,
  });

  @override
  State<CompanySupervisorsScreen> createState() =>
      _CompanySupervisorsScreenState();
}

class _CompanySupervisorsScreenState
    extends State<CompanySupervisorsScreen> {

  List supervisors = [];
  bool isLoading = true;
  bool isDeleting = false;
  bool isError = false;

  final String baseUrl = "http://192.168.1.3:3000/api";

  @override
  void initState() {
    super.initState();
    fetchSupervisors();
  }

  /// 🔥 جلب المشرفين
  Future<void> fetchSupervisors() async {

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {

      final res = await http.get(
        Uri.parse("$baseUrl/supervisors?companyCode=${widget.companyCode}"),
      );

      final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200 && data["success"] == true) {

        setState(() {
          supervisors = data["supervisors"] ?? [];
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

  /// 🗑️ حذف مشرف
  Future<void> deleteSupervisor(String id) async {

    setState(() => isDeleting = true);

    try {

      final res = await http.delete(
        Uri.parse("$baseUrl/supervisors/$id"),
      );

      final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200 && data["success"] == true) {

        showMsg("تم الحذف ✅");

        /// تحديث القائمة
        fetchSupervisors();

      } else {

        showMsg(data["message"] ?? "فشل الحذف ❌");

      }

    } catch (e) {

      showMsg("خطأ في الاتصال ❌");

    }

    setState(() => isDeleting = false);
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
        title: const Text("مشرفين الشركة"),
        centerTitle: true,
      ),

      body: Stack(
        children: [

          /// 🔥 حالات الشاشة
          if (isLoading)
            const Center(child: CircularProgressIndicator())

          else if (isError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text("حدث خطأ ❌"),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: fetchSupervisors,
                    child: const Text("إعادة المحاولة"),
                  )

                ],
              ),
            )

          else if (supervisors.isEmpty)
            const Center(
              child: Text("لا يوجد مشرفين حالياً"),
            )

          else
            RefreshIndicator(
              onRefresh: fetchSupervisors,
              child: ListView.builder(
                itemCount: supervisors.length,
                itemBuilder: (context, index) {

                  final item = supervisors[index];

                  final id = item["id"].toString();
                  final name = item["name"] ?? "بدون اسم";
                  final phone = item["phone"] ?? "غير متوفر";
                  final office = item["office"] ?? "غير محدد";

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ListTile(

                      leading: const CircleAvatar(
                        radius: 25,
                        child: Icon(Icons.person),
                      ),

                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const SizedBox(height: 5),
                          Text("📞 $phone"),
                          Text("📍 $office"),

                        ],
                      ),

                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(

                              title: const Text("تأكيد الحذف"),
                              content: const Text("هل تريد حذف هذا المشرف؟"),

                              actions: [

                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("إلغاء"),
                                ),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    deleteSupervisor(id);
                                  },
                                  child: const Text("حذف"),
                                ),

                              ],
                            ),
                          );

                        },
                      ),

                    ),
                  );
                },
              ),
            ),

          /// 🔥 لودر الحذف
          if (isDeleting)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}