import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'supervisor_dashboard_screen.dart';

class SupervisorRegisterScreen extends StatefulWidget {
  const SupervisorRegisterScreen({super.key});

  @override
  State<SupervisorRegisterScreen> createState() =>
      _SupervisorRegisterScreenState();
}

class _SupervisorRegisterScreenState
    extends State<SupervisorRegisterScreen> {

  final nameController = TextEditingController();
  final officeController = TextEditingController();
  final phoneController = TextEditingController();
  final companyCodeController = TextEditingController();

  bool isLoading = false;

  /// 🔥 تسجيل عبر API SERVICE
  Future<void> registerSupervisor() async {

    final name = nameController.text.trim();
    final office = officeController.text.trim();
    final phone = phoneController.text.trim();
    final code = companyCodeController.text.trim();

    if (name.isEmpty || office.isEmpty || phone.isEmpty || code.isEmpty) {
      showMsg("أدخل كل البيانات");
      return;
    }

    setState(() => isLoading = true);

    try {

      final data = await ApiService.registerSupervisor(
        name: name,
        office: office,
        phone: phone,
        companyCode: code,
      );

      if (data["success"] == true) {

        String companyName = data["companyName"] ?? "";
        String tripCode = data["tripCode"] ?? "";
        String category = data["category"] ?? "company";

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SupervisorDashboardScreen(
              companyName: companyName,
              supervisorName: name,
              officeLocation: office,
              companyCode: code,
              tripCode: tripCode,
              category: category,
              supervisorPhone: phone,
            ),
          ),
        );

        showMsg("تم تسجيل المشرف بنجاح ✅");

      } else {
        showMsg(data["message"] ?? "فشل التسجيل ❌");
      }

    } catch (e) {
      showMsg("خطأ في الاتصال بالسيرفر ❌");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void showMsg(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    officeController.dispose();
    phoneController.dispose();
    companyCodeController.dispose();
    super.dispose();
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? type,
  }) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل مشرف")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          buildField(
            controller: nameController,
            label: "اسم المشرف",
          ),

          buildField(
            controller: officeController,
            label: "موقع المكتب",
          ),

          buildField(
            controller: phoneController,
            label: "رقم الهاتف",
            type: TextInputType.phone,
          ),

          buildField(
            controller: companyCodeController,
            label: "كود الشركة",
          ),

          const SizedBox(height: 10),

          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: registerSupervisor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "تسجيل",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}