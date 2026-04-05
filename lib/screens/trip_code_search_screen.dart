import 'package:flutter/material.dart';
import 'trip_list_screen.dart';

class TripCodeSearchScreen extends StatefulWidget {
  const TripCodeSearchScreen({super.key});

  @override
  State<TripCodeSearchScreen> createState() =>
      _TripCodeSearchScreenState();
}

class _TripCodeSearchScreenState extends State<TripCodeSearchScreen> {

  final TextEditingController codeController = TextEditingController();

  String detectCategory(String code) {

    code = code.toUpperCase();

    if (code.startsWith("COMPANY")) return "company";
    if (code.startsWith("CAR")) return "car";
    if (code.startsWith("MILITARY")) return "military";
    if (code.startsWith("SHIPPING")) return "shipping";

    return "";
  }

  String detectTripType(String category) {
    switch (category) {
      case "company":
        return "voluntary";
      case "car":
        return "private";
      case "military":
        return "military";
      case "shipping":
        return "shipping";
      default:
        return "voluntary";
    }
  }

  void search() {

    String code = codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      showMsg("ادخل الكود");
      return;
    }

    String category = detectCategory(code);

    if (category.isEmpty) {
      showMsg("❌ الكود غير صحيح");
      return;
    }

    String tripType = detectTripType(category);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripListScreen(
          tripType: tripType,
          category: category,
        ),
      ),
    );
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
        title: const Text("عرض الرحلات بالكود"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.qr_code,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              "أدخل كود الرحلات",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: codeController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "مثال: COMPANYXXXXX أو CARXXXXX",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: search,
                child: const Text(
                  "عرض الرحلات",
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