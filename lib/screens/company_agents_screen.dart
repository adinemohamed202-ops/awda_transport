import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompanyAgentsScreen extends StatefulWidget {
  final String companyCode;

  const CompanyAgentsScreen({
    super.key,
    required this.companyCode,
  });

  @override
  State<CompanyAgentsScreen> createState() => _CompanyAgentsScreenState();
}

class _CompanyAgentsScreenState extends State<CompanyAgentsScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController officeController = TextEditingController();

  bool isLoading = false;
  bool loadingList = true;

  List supervisors = [];

  final String baseUrl = "http://192.168.1.3:3000/api";

  @override
  void initState() {
    super.initState();
    fetchSupervisors();
  }

  /// ===========================
  /// 📥 جلب المشرفين
  /// ===========================
  Future<void> fetchSupervisors() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/supervisors/${widget.companyCode}"),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"]) {
        setState(() {
          supervisors = data["supervisors"];
          loadingList = false;
        });
      } else {
        showMsg("فشل تحميل البيانات ❌");
      }
    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
    }
  }

  /// ===========================
  /// ➕ إضافة مشرف
  /// ===========================
  Future<void> addSupervisor() async {

    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        officeController.text.isEmpty) {

      showMsg("أكمل كل البيانات");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/supervisors/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "office": officeController.text.trim(),
          "companyCode": widget.companyCode,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"]) {
        clear();
        fetchSupervisors();
        showMsg("تمت إضافة المشرف ✅");
      } else {
        showMsg(data["message"] ?? "فشل العملية ❌");
      }

    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
    }

    setState(() => isLoading = false);
  }

  /// ===========================
  /// 🗑️ حذف مشرف
  /// ===========================
  Future<void> deleteSupervisor(String id) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/supervisors/delete/$id"),
      );

      final data = jsonDecode(res.body);

      if (data["success"]) {
        fetchSupervisors();
        showMsg("تم الحذف 🗑️");
      } else {
        showMsg("فشل الحذف ❌");
      }
    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
    }
  }

  void clear() {
    nameController.clear();
    phoneController.clear();
    officeController.clear();
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /// ===========================
  /// 🧾 Dialog
  /// ===========================
  void openAddDialog() {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("إضافة مشرف"),
          content: SingleChildScrollView(
            child: Column(
              children: [

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "اسم المشرف"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "رقم الهاتف"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: officeController,
                  decoration: const InputDecoration(labelText: "موقع المكتب"),
                ),

              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),

            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      await addSupervisor();
                      Navigator.pop(context);
                    },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("حفظ"),
            ),

          ],
        );
      },
    );
  }

  /// ===========================
  /// UI
  /// ===========================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة المشرفين"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openAddDialog,
        child: const Icon(Icons.add),
      ),

      body: loadingList
          ? const Center(child: CircularProgressIndicator())
          : supervisors.isEmpty
              ? const Center(child: Text("لا يوجد مشرفين"))
              : RefreshIndicator(
                  onRefresh: fetchSupervisors,
                  child: ListView.builder(
                    itemCount: supervisors.length,
                    itemBuilder: (context, index) {

                      var data = supervisors[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 3,
                        child: ListTile(

                          title: Text(data["name"] ?? ""),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("📞 ${data["phone"] ?? ""}"),
                              Text("📍 ${data["office"] ?? ""}"),
                            ],
                          ),

                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteSupervisor(data["id"]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}