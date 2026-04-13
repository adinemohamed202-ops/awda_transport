import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vehicle_codes_screen.dart';

class VehicleRegisterScreen extends StatefulWidget {
  const VehicleRegisterScreen({super.key});

  @override
  State<VehicleRegisterScreen> createState() =>
      _VehicleRegisterScreenState();
}

class _VehicleRegisterScreenState extends State<VehicleRegisterScreen> {

  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController seatsController = TextEditingController();

  String vehicleType = "سيارة";
  bool isLoading = false;

  /// 🔥 API URL
  final String baseUrl = "http://YOUR_SERVER_IP:3000";

  String generateCode(int length) {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> registerVehicle() async {

    if (driverNameController.text.isEmpty ||
        plateNumberController.text.isEmpty ||
        seatsController.text.isEmpty) {

      showMsg("أكمل كل البيانات");
      return;
    }

    int seats = int.tryParse(seatsController.text) ?? 0;
    if (seats <= 0) {
      showMsg("عدد المقاعد غير صحيح");
      return;
    }

    setState(() => isLoading = true);

    try {
      String supervisorCode = "SUP${generateCode(5)}";
      String tripCode = "CARTRP${generateCode(4)}";

      final response = await http.post(
        Uri.parse("$baseUrl/vehicles/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "driverName": driverNameController.text.trim(),
          "vehicleType": vehicleType,
          "plateNumber": plateNumberController.text.trim(),
          "seats": seats,
          "supervisorCode": supervisorCode,
          "tripCode": tripCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        showMsg(data["message"] ?? "❌ خطأ في التسجيل");
        setState(() => isLoading = false);
        return;
      }

      /// 🔥 القيم من السيرفر
      String finalSupervisorCode = data["supervisorCode"];
      String finalTripCode = data["tripCode"];

      /// 🔥 توحيد ID (بدون كسر النظام)
      String vehicleId =
          data["id"]?.toString() ??
          data["vehicleId"]?.toString() ??
          finalTripCode;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VehicleCodesScreen(
            supervisorCode: finalSupervisorCode,
            tripsCode: finalTripCode,
          ),
        ),
      );

      clear();

    } catch (e) {
      showMsg("❌ تأكد من الاتصال بالسيرفر");
    }

    setState(() => isLoading = false);
  }

  void clear() {
    driverNameController.clear();
    plateNumberController.clear();
    seatsController.clear();
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
        title: const Text("تسجيل عربة"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            TextField(
              controller: driverNameController,
              decoration: const InputDecoration(
                labelText: "اسم السائق",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: plateNumberController,
              decoration: const InputDecoration(
                labelText: "رقم اللوحة",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: seatsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "عدد المقاعد",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: vehicleType,
              items: const [
                DropdownMenuItem(value: "سيارة", child: Text("سيارة")),
                DropdownMenuItem(value: "هايس", child: Text("هايس")),
                DropdownMenuItem(value: "استايركس", child: Text("استايركس")),
                DropdownMenuItem(value: "شريحة", child: Text("شريحة")),
                DropdownMenuItem(value: "حافلة", child: Text("حافلة")),
              ],
              onChanged: (value) {
                setState(() {
                  vehicleType = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "نوع العربة",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: registerVehicle,
                      child: const Text(
                        "تسجيل",
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