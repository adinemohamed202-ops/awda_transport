import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BuyCreditScreen extends StatefulWidget {
  const BuyCreditScreen({super.key});

  @override
  State<BuyCreditScreen> createState() => _BuyCreditScreenState();
}

class _BuyCreditScreenState extends State<BuyCreditScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController walletController = TextEditingController();

  String verificationCode = "";
  bool loading = true;

  /// 🔥 رابط السيرفر
  final String baseUrl = "http://192.168.1.3:3000/api";

  @override
  void initState() {
    super.initState();
    generateCode();
  }

  /// 🔑 جلب كود التحقق من السيرفر
  Future<void> generateCode() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/topup/code"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          verificationCode = data["code"];
          loading = false;
        });
      } else {
        showMsg("فشل تحميل الكود ❌");
        setState(() => loading = false);
      }
    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
      setState(() => loading = false);
    }
  }

  /// 📤 إرسال الطلب
  Future<void> sendRequest() async {
    if (amountController.text.isEmpty ||
        walletController.text.isEmpty) {
      showMsg("املأ كل الحقول ⚠️");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/topup/request"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": int.parse(amountController.text),
          "walletNumber": walletController.text,
          "code": verificationCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        showMsg("تم إرسال الطلب للمراجعة ✅");

        amountController.clear();
        walletController.clear();

        /// 🔄 كود جديد
        generateCode();
      } else {
        showMsg("فشل الإرسال ❌");
      }
    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
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
        title: const Text("شراء كريدت"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  "رقم الحساب للتحويل",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text(
                    "123456789",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "رمز التحقق",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    verificationCode,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "⚠️ يجب كتابة رمز التحقق في تعليق التحويل",
                  style: TextStyle(color: Colors.red),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "المبلغ",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: walletController,
                  decoration: const InputDecoration(
                    labelText: "رقم المحفظة",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: sendRequest,
                    child: const Text("إرسال الطلب"),
                  ),
                )
              ],
            ),
    );
  }
}