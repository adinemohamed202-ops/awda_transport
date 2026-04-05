import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class VerifyScreen extends StatefulWidget {
  final String email;
  final String username;

  const VerifyScreen({
    super.key,
    required this.email,
    required this.username,
  });

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {

  final TextEditingController codeController = TextEditingController();

  bool isLoading = false;
  bool isResending = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  /// ✅ تأكيد الكود
  Future<void> verify() async {

    String code = codeController.text.trim();

    if (code.isEmpty) {
      showMsg("أدخل كود التحقق");
      return;
    }

    if (code.length < 4) {
      showMsg("الكود غير صحيح");
      return;
    }

    setState(() => isLoading = true);

    try {

      final response = await ApiService.verifyCode(
        widget.email,
        code,
      );

      if (!mounted) return;

      if (response["success"] == true) {

        showMsg("تم توثيق الحساب ✅");

        /// 🔥 يرجع لتسجيل الدخول
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );

      } else {
        showMsg(response["message"] ?? "الكود غير صحيح");
      }

    } catch (e) {
      if (!mounted) return;
      showMsg("خطأ في الاتصال بالسيرفر");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  /// 🔁 إعادة إرسال الكود
  Future<void> resendCode() async {

    setState(() => isResending = true);

    try {

      final response = await ApiService.resendCode(widget.email);

      if (!mounted) return;

      if (response["success"] == true) {
        showMsg("تم إرسال الكود مرة أخرى 📩");
      } else {
        showMsg(response["message"] ?? "فشل إعادة الإرسال");
      }

    } catch (e) {
      if (!mounted) return;
      showMsg("خطأ في الاتصال بالسيرفر");
    }

    if (mounted) {
      setState(() => isResending = false);
    }
  }

  void showMsg(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("تأكيد الحساب")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 30),

            Text(
              "أدخل الكود المرسل إلى",
              style: TextStyle(color: Colors.grey[700]),
            ),

            const SizedBox(height: 5),

            Text(
              widget.email,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "كود التحقق",
                prefixIcon: Icon(Icons.verified),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : verify,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("تأكيد"),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: isResending ? null : resendCode,
              child: isResending
                  ? const Text("جاري الإرسال...")
                  : const Text("إعادة إرسال الكود"),
            ),
          ],
        ),
      ),
    );
  }
}