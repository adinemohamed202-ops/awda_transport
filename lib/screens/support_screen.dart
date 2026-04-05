import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../utils/user_session.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  /// 🔥 الجديد
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController walletController = TextEditingController();

  File? imageFile;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    /// تعبئة تلقائية من السيشن
    userIdController.text = UserSession.uid;
    walletController.text = UserSession.wallet;
    nameController.text = UserSession.name;
  }

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  /// 🚀 إرسال البلاغ
  Future<void> sendMessage() async {

    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        messageController.text.isEmpty ||
        userIdController.text.isEmpty ||
        walletController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ملء كل الحقول")),
      );
      return;
    }

    try {

      final response = await ApiService.postWithFile(
        "/support",
        {
          "name": nameController.text.trim(),
          "userId": userIdController.text.trim(),
          "walletId": walletController.text.trim(),
          "phone": phoneController.text.trim(),
          "message": messageController.text.trim(),
        },
        file: imageFile,
        fileField: "image",
      );

      if (response["success"] == true) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم إرسال البلاغ بنجاح")),
        );

        /// تنظيف
        phoneController.clear();
        messageController.clear();

        setState(() {
          imageFile = null;
        });

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "فشل الإرسال")),
        );

      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ في السيرفر ❌")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("الدعم الفني"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const Text(
            "إرسال بلاغ أو مشكلة",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "اسم المستخدم",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: userIdController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "User ID",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: walletController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "رقم المحفظة",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "رقم الهاتف",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: messageController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "شرح المشكلة",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          if (imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(imageFile!, height: 150),
            ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: pickImage,
            icon: const Icon(Icons.image),
            label: const Text("إرفاق صورة"),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: sendMessage,
              child: const Text("إرسال البلاغ"),
            ),
          )

        ],
      ),

    );
  }
}