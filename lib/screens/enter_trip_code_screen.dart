import 'package:flutter/material.dart';
import 'company_trips_screen.dart';

class EnterTripCodeScreen extends StatefulWidget {

  final String companyCode; // 🔥 لازم يجي من برا

  const EnterTripCodeScreen({
    super.key,
    required this.companyCode,
  });

  @override
  State<EnterTripCodeScreen> createState() =>
      _EnterTripCodeScreenState();
}

class _EnterTripCodeScreenState
    extends State<EnterTripCodeScreen> {

  final TextEditingController codeController =
      TextEditingController();

  @override
  void dispose() {
    codeController.dispose(); // 🔥 مهم جداً
    super.dispose();
  }

  void goToTrips() {

    final code = codeController.text.trim();

    if (code.isEmpty) {
      showMsg("ادخل كود الرحلات");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyTripsScreen(
          companyCode: widget.companyCode,
          tripsCode: code,
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
        title: const Text("ادخل كود الرحلات"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: "كود الرحلات",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.confirmation_number),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: goToTrips,
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