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

  @override
  void dispose() {
    problemController.dispose();
    super.dispose();
  }

  Future<void> sendProblem() async {

    FocusScope.of(context).unfocus();

    String text = problemController.text.trim();

    if (text.isEmpty) {
      showMsg("اكتب المشكلة أول");
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
        showMsg("تم إرسال المشكلة ✅");
      } else {
        showMsg(response["message"] ?? "فشل الإرسال");
      }

    } catch (e) {
      if (!mounted) return;
      showMsg("خطأ في الاتصال بالسيرفر");
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
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "اكتب مشكلتك هنا...",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendProblem,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("إرسال"),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}