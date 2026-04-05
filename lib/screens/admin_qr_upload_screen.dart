import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AdminQrUploadScreen extends StatefulWidget {
  const AdminQrUploadScreen({super.key});

  @override
  State<AdminQrUploadScreen> createState() => _AdminQrUploadScreenState();
}

class _AdminQrUploadScreenState extends State<AdminQrUploadScreen> {
  File? image;
  String? currentQrUrl;
  bool loading = false;
  bool loadingQr = true;

  final picker = ImagePicker();

  /// 🔥 رابط السيرفر
  final String baseUrl = "http://192.168.1.3:3000/api";

  @override
  void initState() {
    super.initState();
    fetchCurrentQR();
  }

  /// 📥 جلب QR الحالي من السيرفر
  Future<void> fetchCurrentQR() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/admin/get-qr"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data["success"] == true) {
          setState(() {
            currentQrUrl = data["qr"];
          });
        }
      }
    } catch (e) {
      showMsg("فشل جلب QR الحالي ❌");
    }

    setState(() => loadingQr = false);
  }

  /// 📷 اختيار صورة
  Future<void> pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() {
          image = File(picked.path);
        });
      }
    } catch (e) {
      showMsg("فشل اختيار الصورة ❌");
    }
  }

  /// 🚀 رفع QR
  Future<void> uploadQR() async {
    if (image == null) {
      showMsg("اختر صورة أولاً");
      return;
    }

    setState(() => loading = true);

    try {
      final uri = Uri.parse("$baseUrl/admin/upload-qr");

      var request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('qr', image!.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final data = jsonDecode(resBody);

        if (data["success"] == true) {
          showMsg("تم رفع QR بنجاح ✅");

          setState(() {
            image = null;
          });

          /// 🔄 تحديث QR بعد الرفع
          fetchCurrentQR();
        } else {
          showMsg(data["message"] ?? "فشل الرفع ❌");
        }
      } else {
        showMsg("خطأ من السيرفر (${response.statusCode}) ❌");
      }
    } catch (e) {
      showMsg("خطأ في الاتصال بالسيرفر ❌");
    }

    setState(() => loading = false);
  }

  /// 💬 رسالة
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
        title: const Text("QR الأدمن"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔳 QR الحالي
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "QR الحالي",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            if (loadingQr)
              const CircularProgressIndicator()
            else if (currentQrUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  currentQrUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Text("لا يوجد QR مرفوع"),

            const SizedBox(height: 30),

            /// 📷 الصورة الجديدة
            if (image != null)
              Column(
                children: [
                  const Text("QR الجديد"),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(image!, height: 200),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

            /// اختيار صورة
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pickImage,
                child: const Text("اختيار صورة QR"),
              ),
            ),

            const SizedBox(height: 15),

            /// رفع
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : uploadQR,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("رفع QR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}