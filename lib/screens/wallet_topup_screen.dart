// wallet_topup_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/wallet_service.dart';
import '../models/wallet_transaction.dart';

class WalletTopUpScreen extends StatefulWidget {
  const WalletTopUpScreen({super.key});

  @override
  State<WalletTopUpScreen> createState() => _WalletTopUpScreenState();
}

class _WalletTopUpScreenState extends State<WalletTopUpScreen> {
  String dynamicCode = "";
  Timer? timer;

  final String accountNumber = "3703040";
  final String accountName = "عدني محمد سبت عبدالمحمود";

  final TextEditingController amountController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    generateCode();

    timer = Timer.periodic(const Duration(minutes: 10), (_) {
      generateCode();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    amountController.dispose();
    commentController.dispose();
    super.dispose();
  }

  void generateCode() {
    String code = "";
    Random rnd = Random();

    for (int i = 0; i < 7; i++) {
      code += rnd.nextInt(10).toString();
    }

    setState(() {
      dynamicCode = "$code-awda";
    });
  }

  Future<void> confirmTopUp() async {
    String comment = commentController.text.trim();
    int? amount = int.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أدخل مبلغ صالح")),
      );
      return;
    }

    if (!comment.contains(dynamicCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الكود في التعليق غير صحيح")),
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الشحن"),
        content: Text("هل تريد شحن المحفظة بمبلغ $amount كريت؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("تأكيد"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 🔥 تحويل النوع إذا كان مخزن Map
    WalletService.balance += amount;

    WalletService.transactions.add(
      WalletTransaction(
        title: "شحن المحفظة",
        amount: amount,
        date: DateTime.now(),
      ),
    );

    amountController.clear();
    commentController.clear();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم شحن المحفظة بمبلغ $amount كريت ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    String qrData =
        "account:$accountNumber,name:$accountName,code:$dynamicCode";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        title: const Text("شحن المحفظة"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "امسح هذا الكود عبر تطبيق بنكك لإتمام الدفع",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: QrImageView(
                data: qrData,
                size: 250,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "الرمز الحالي للتعليقات:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            SelectableText(
              dynamicCode,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text("نسخ الرمز"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: dynamicCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم نسخ الرمز")),
                );
              },
            ),

            const SizedBox(height: 30),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "المبلغ الذي أرسلته",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: "الكود في التعليقات",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: confirmTopUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  "تأكيد الدفع وشحن المحفظة",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "رصيد المحفظة الحالي: ${WalletService.balance} كريت",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 25),

            if (WalletService.transactions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "سجل المعاملات:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...WalletService.transactions.reversed.map((tx) {
                    final WalletTransaction transaction =
                        tx as WalletTransaction;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(transaction.title),
                        subtitle: Text(
                          "${transaction.date.toLocal()}".split('.')[0],
                        ),
                        trailing: Text(
                          "${transaction.amount} كريت",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}