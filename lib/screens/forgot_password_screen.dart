import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final TextEditingController emailController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> resetPassword() async {

    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMsg("أدخل البريد الإلكتروني");
      return;
    }

    if (!isValidEmail(email)) {
      showMsg("بريد غير صالح ❌");
      return;
    }

    setState(() => isLoading = true);

    try {

      /// 🔥 عبر ApiService
      final response = await ApiService.resendCode(email);

      if (!mounted) return;

      if (response["success"] == true) {

        showMsg("تم إرسال كود إعادة التعيين 📩");

        Navigator.pop(context);

      } else {

        showMsg(response["message"] ?? "فشل العملية ❌");

      }

    } catch (e) {

      if (!mounted) return;
      showMsg("خطأ في الاتصال ❌");

    }

    if (mounted) {
      setState(() => isLoading = false);
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
        title: const Text("نسيت كلمة المرور"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 40),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "البريد الإلكتروني",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : resetPassword,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "إرسال",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}