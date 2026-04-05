import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'company_trips_screen.dart';

class VehicleCodesScreen extends StatelessWidget {

  final String supervisorCode;
  final String tripsCode;

  const VehicleCodesScreen({
    super.key,
    required this.supervisorCode,
    required this.tripsCode,
  });

  void copyCode(BuildContext context, String code, String message) {
    Clipboard.setData(ClipboardData(text: code));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildCard({
    required BuildContext context,
    required String title,
    required String code,
    required String message,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          code,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy, color: Colors.blue),
          onPressed: () => copyCode(context, code, message),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("أكواد العربة"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// 🔥 كود المشرف (بدل الشركة)
            buildCard(
              context: context,
              title: "كود المشرف",
              code: supervisorCode,
              message: "تم نسخ كود المشرف",
            ),

            const SizedBox(height: 20),

            /// 🔥 كود الرحلات
            buildCard(
              context: context,
              title: "كود عرض الرحلات",
              code: tripsCode,
              message: "تم نسخ كود الرحلات",
            ),

            const SizedBox(height: 30),

            /// 🔥 زر عرض الرحلات
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions_bus),
                label: const Text("عرض الرحلات"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompanyTripsScreen(
                        companyCode: supervisorCode, // 🔥 استخدمناه كمعرف
                        tripsCode: tripsCode,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "احفظ هذه الأكواد لاستخدامها لاحقاً",
              style: TextStyle(color: Colors.grey),
            ),

          ],
        ),
      ),
    );
  }
}