import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/user_session.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final TextEditingController problemController = TextEditingController();
  bool isLoading = false;

  int maxLength = 500;

  @override
  void dispose() {
    problemController.dispose();
    super.dispose();
  }

  Future<void> sendProblem() async {
    if (isLoading) return;

    FocusScope.of(context).unfocus();

    String text = problemController.text.trim();

    if (text.isEmpty) {
      showMsg("اكتب المشكلة أول");
      return;
    }

    if (text.length < 5) {
      showMsg("اكتب تفاصيل أكثر");
      return;
    }

    if (UserSession.userId == null) {
      showMsg("يجب تسجيل الدخول أولاً");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService.sendSupport(
        userId: UserSession.userId!,
        message: text,
      );

      if (!mounted) return;

      if (response["success"] == true) {
        problemController.clear();
        showMsg("تم إرسال المشكلة بنجاح ✅");
      } else {
        showMsg(response["message"] ?? "فشل الإرسال");
      }
    } catch (e) {
      if (!mounted) return;
      showMsg("خطأ في الاتصال بالسيرفر ❌");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void showMsg(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الدعم الفني"),
        centerTitle: true,
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              TextField(
                controller: problemController,
                maxLines: 6,
                maxLength: maxLength,
                decoration: const InputDecoration(
                  hintText: "اكتب مشكلتك هنا...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendProblem,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "إرسال",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}