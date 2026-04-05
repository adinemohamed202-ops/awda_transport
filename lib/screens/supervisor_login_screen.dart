import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'supervisor_dashboard_screen.dart';

class SupervisorLoginScreen extends StatefulWidget {
  const SupervisorLoginScreen({super.key});

  @override
  State<SupervisorLoginScreen> createState() =>
      _SupervisorLoginScreenState();
}

class _SupervisorLoginScreenState
    extends State<SupervisorLoginScreen> {

  final nameController = TextEditingController();
  final officeController = TextEditingController();
  final phoneController = TextEditingController();
  final codeController = TextEditingController();

  bool isLoading = false;

  /// 🔥 تسجيل / دخول عبر API
  Future<void> loginOrRegisterSupervisor() async {

    final name = nameController.text.trim();
    final office = officeController.text.trim();
    final phone = phoneController.text.trim();
    final code = codeController.text.trim();

    if (name.isEmpty || office.isEmpty || phone.isEmpty || code.isEmpty) {
      showMsg("أدخل كل البيانات");
      return;
    }

    setState(() => isLoading = true);

    try {

      final response = await ApiService.postWithFile(
        "/supervisor/login",
        {
          "name": name,
          "office": office,
          "phone": phone,
          "code": code,
        },
      );

      if (response["success"] != true) {
        showMsg(response["message"] ?? "❌ خطأ في الدخول");
        setState(() => isLoading = false);
        return;
      }

      /// 🔥 نفس المتغيرات
      String category = response["category"];
      String companyName = response["companyName"];
      String tripCode = response["tripCode"];

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

    } catch (e) {
      showMsg("حدث خطأ ❌");
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
    codeController.dispose();
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
      appBar: AppBar(title: const Text("دخول المشرف")),
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
            controller: codeController,
            label: "كود الدخول",
          ),

          const SizedBox(height: 10),

          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: loginOrRegisterSupervisor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "دخول",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}