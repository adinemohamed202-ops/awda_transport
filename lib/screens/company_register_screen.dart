import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'company_code_screen.dart';

class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({super.key});

  @override
  State<CompanyRegisterScreen> createState() =>
      _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String selectedType = "transport";
  String idType = "passport";

  File? passportImage;
  File? idFront;
  File? idBack;
  File? faceImage;

  bool isLoading = false;

  final picker = ImagePicker();
  final String baseUrl = "http://192.168.1.3:3000/api";

  /// 📸 التقاط صورة من الكاميرا فقط
  Future<File?> pickFromCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  /// 🔐 تسجيل الشركة
  void registerCompany() async {

    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      showMsg("أكمل البيانات");
      return;
    }

    if (idType == "passport" && passportImage == null) {
      showMsg("ارفع صورة الجواز");
      return;
    }

    if (idType == "card" && (idFront == null || idBack == null)) {
      showMsg("ارفع صور البطاقة (أمام + خلف)");
      return;
    }

    if (faceImage == null) {
      showMsg("التقط صورة شخصية");
      return;
    }

    setState(() => isLoading = true);

    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/companies/register"),
      );

      request.fields['name'] = nameController.text.trim();
      request.fields['phone'] = phoneController.text.trim();
      request.fields['category'] = selectedType;
      request.fields['idType'] = idType;

      if (passportImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'passportImage',
          passportImage!.path,
        ));
      }

      if (idFront != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'idFront',
          idFront!.path,
        ));
      }

      if (idBack != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'idBack',
          idBack!.path,
        ));
      }

      request.files.add(await http.MultipartFile.fromPath(
        'faceImage',
        faceImage!.path,
      ));

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      final data = jsonDecode(res.body);

      if (response.statusCode == 201) {

        showMsg("تم التسجيل بنجاح ✅");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CompanyCodeScreen(
              companyCode: data["companyCode"],
              tripsCode: data["tripCode"],
            ),
          ),
        );

      } else {
        showMsg(data["message"] ?? "فشل التسجيل");
      }

    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
    }

    setState(() => isLoading = false);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget buildImageButton(String title, VoidCallback onTap, File? file) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap,
          child: Text(title),
        ),
        if (file != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Image.file(file, height: 100),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل شركة"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            /// نوع الشركة
            DropdownButtonFormField(
              value: selectedType,
              items: const [
                DropdownMenuItem(value: "transport", child: Text("شركة نقل")),
                DropdownMenuItem(value: "shipping", child: Text("شركة شحن")),
                DropdownMenuItem(value: "sud", child: Text("شركة طوعية SUD")),
              ],
              onChanged: (v) => setState(() => selectedType = v!),
              decoration: const InputDecoration(
                labelText: "نوع الشركة",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "اسم الشركة",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "رقم الهاتف",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// نوع الهوية
            DropdownButtonFormField(
              value: idType,
              items: const [
                DropdownMenuItem(value: "passport", child: Text("جواز")),
                DropdownMenuItem(value: "card", child: Text("بطاقة")),
              ],
              onChanged: (v) => setState(() => idType = v!),
              decoration: const InputDecoration(
                labelText: "نوع الهوية",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            /// صور الهوية
            if (idType == "passport")
              buildImageButton(
                "تصوير الجواز",
                () async {
                  passportImage = await pickFromCamera();
                  setState(() {});
                },
                passportImage,
              ),

            if (idType == "card") ...[
              buildImageButton(
                "تصوير البطاقة (أمام)",
                () async {
                  idFront = await pickFromCamera();
                  setState(() {});
                },
                idFront,
              ),
              buildImageButton(
                "تصوير البطاقة (خلف)",
                () async {
                  idBack = await pickFromCamera();
                  setState(() {});
                },
                idBack,
              ),
            ],

            const SizedBox(height: 20),

            /// صورة الوجه
            buildImageButton(
              "تصوير الوجه (من الكاميرا)",
              () async {
                faceImage = await pickFromCamera();
                setState(() {});
              },
              faceImage,
            ),

            const SizedBox(height: 30),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: registerCompany,
                    child: const Text("تسجيل"),
                  ),

          ],
        ),
      ),
    );
  }
}