import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../services/wallet_service.dart';
import '../services/ticket_service.dart';
import '../utils/user_session.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  String code = "";
  Timer? timer;
  Timer? balanceTimer;

  File? receiptImage;

  bool isLoading = false;
  int balance = 0;

  /// 🔳 QR من السيرفر
  String? qrUrl;
  bool loadingQr = true;

  final amountController = TextEditingController();

  final String baseUrl = "http://10.0.2.2:3000/api";

  @override
  void initState() {
    super.initState();
    generateCode();
    loadBalance();
    fetchQR();

    timer = Timer.periodic(const Duration(minutes: 10), (t) {
      generateCode();
    });

    balanceTimer = Timer.periodic(const Duration(seconds: 15), (t) {
      loadBalance();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    balanceTimer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  /// 🔐 توليد الكود
  void generateCode() {
    int number = 100000 + Random().nextInt(900000);
    setState(() {
      code = "awda_$number";
    });
  }

  /// 💰 جلب الرصيد
  Future<void> loadBalance() async {
    try {
      final b = await WalletService.getBalance(
        UserSession.userId,
      );
      setState(() {
        balance = b;
      });
    } catch (e) {
      balance = 0;
    }
  }

  /// 🔳 جلب QR
  Future<void> fetchQR() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/admin/get-qr"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data["success"] == true) {
          setState(() {
            qrUrl = data["qr"];
          });
        }
      }
    } catch (e) {
      showMsg("فشل تحميل QR ❌");
    }

    setState(() => loadingQr = false);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /// 📷 اختيار إيصال
  Future pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        receiptImage = File(picked.path);
      });
    }
  }

  /// 💸 إرسال طلب إيداع
  Future sendDeposit() async {
    int amount = int.tryParse(amountController.text) ?? 0;

    if (amount <= 0) return showMsg("أدخل مبلغ صحيح");
    if (receiptImage == null) return showMsg("ارفع صورة الإيصال");

    setState(() => isLoading = true);

    try {
      bool success = await TicketService.createDepositRequest(
        amount: amount,
        userId: UserSession.userId,
        walletId: UserSession.walletId,
        code: code,
        image: receiptImage!,
      );

      if (success) {
        showMsg("تم إرسال طلب الإيداع ✅");
        amountController.clear();
        receiptImage = null;
        generateCode();
        setState(() {});
      } else {
        showMsg("فشل الإرسال ❌");
      }

    } catch (e) {
      showMsg("فشل الإرسال ❌");
    }

    setState(() => isLoading = false);
  }

  /// 🚨 مشكلة إيداع
  Future sendProblem() async {
    if (receiptImage == null) return showMsg("ارفع صورة الإيصال");

    setState(() => isLoading = true);

    try {
      bool success = await TicketService.createDepositIssue(
        userId: UserSession.userId,
        walletId: UserSession.walletId,
        code: code,
        image: receiptImage!,
      );

      if (success) {
        showMsg("تم إرسال المشكلة ✅");
      } else {
        showMsg("فشل الإرسال ❌");
      }

    } catch (e) {
      showMsg("فشل الإرسال ❌");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    Color primary = const Color(0xFF6A1B9A);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("المحفظة"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/tickets');
            },
          )
        ],
      ),
      body: Stack(
        children: [

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                Text(UserSession.username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18)),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ID: ${UserSession.userId}",
                        style: const TextStyle(color: Colors.white)),
                    Text("Wallet: ${UserSession.walletId}",
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),

                const SizedBox(height: 20),

                /// 💰 الرصيد
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text("رصيدك الحالي",
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 10),
                      Text(
                        "$balance كريت",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔳 QR الحقيقي
                loadingQr
                    ? const CircularProgressIndicator()
                    : qrUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              qrUrl!,
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Text(
                            "لا يوجد QR حالياً",
                            style: TextStyle(color: Colors.white),
                          ),

                const SizedBox(height: 20),

                /// 🔐 الكود
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(code,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        showMsg("تم النسخ");
                      },
                    )
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  "ضع رمز awda في تعليق التحويل لضمان إضافة الرصيد",
                  style: TextStyle(color: Colors.red),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "المبلغ",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text("إرفاق إشعار الدفع"),
                ),

                if (receiptImage != null)
                  Image.file(receiptImage!, height: 120),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: sendDeposit,
                  child: const Text("طلب إيداع"),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: sendProblem,
                  child: const Text("مشكلة إيداع"),
                ),
              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}