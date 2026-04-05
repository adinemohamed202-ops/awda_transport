import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class SupervisorAddTripScreen extends StatefulWidget {
  final String companyName;
  final String supervisorName;
  final String officeLocation;
  final String phoneNumber;
  final String companyCode;
  final String tripCode;
  final String category;

  const SupervisorAddTripScreen({
    super.key,
    required this.companyName,
    required this.supervisorName,
    required this.officeLocation,
    required this.phoneNumber,
    required this.companyCode,
    required this.tripCode,
    required this.category,
  });

  @override
  State<SupervisorAddTripScreen> createState() =>
      _SupervisorAddTripScreenState();
}

class _SupervisorAddTripScreenState extends State<SupervisorAddTripScreen> {

  final fromController = TextEditingController();
  final toController = TextEditingController();
  final seatsController = TextEditingController();
  final priceController = TextEditingController();
  final pickupController = TextEditingController();
  final noteController = TextEditingController();

  DateTime? tripDate;
  TimeOfDay? tripTime;

  String? tripType;
  String? vehicleType;
  bool isLoading = false;

  final String baseUrl = "http://YOUR_SERVER_IP:3000";

  List generateSeats(int total) {
    return List.generate(total, (index) => {"seat": index + 1, "booked": false});
  }

  Future publishTrip() async {
    int seats = int.tryParse(seatsController.text) ?? 0;
    int price = int.tryParse(priceController.text) ?? 0;

    if (tripType == "طوعية") price = 0;

    if (fromController.text.isEmpty ||
        toController.text.isEmpty ||
        seats <= 0 ||
        tripDate == null ||
        tripTime == null ||
        tripType == null ||
        vehicleType == null) {
      showMsg("أكمل كل البيانات");
      return;
    }

    setState(() => isLoading = true);

    try {
      String tripId = "TRIP${Random().nextInt(999999)}"; // ID عشوائي

      List seatsList = generateSeats(seats);

      final response = await http.post(
        Uri.parse("$baseUrl/trips/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tripId": tripId,
          "companyCode": widget.companyCode,
          "tripCode": widget.tripCode,
          "supervisorPhone": widget.phoneNumber,
          "companyName": widget.companyName,
          "supervisorName": widget.supervisorName,
          "officeLocation": widget.officeLocation,
          "phone": widget.phoneNumber,
          "from": fromController.text,
          "to": toController.text,
          "tripType": tripType,
          "vehicleType": vehicleType,
          "seats": seatsList,
          "totalSeats": seats,
          "bookedSeats": 0,
          "price": price,
          "pickupPoint": pickupController.text,
          "note": noteController.text,
          "date": tripDate!.toIso8601String(),
          "time": tripTime!.format(context),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        showMsg(data["message"] ?? "❌ خطأ في نشر الرحلة");
        setState(() => isLoading = false);
        return;
      }

      showMsg("تم نشر الرحلة ✅");
      Navigator.pop(context);

    } catch (e) {
      showMsg("❌ تأكد من الاتصال بالسيرفر");
    }

    setState(() => isLoading = false);
  }

  Future pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (picked != null) setState(() => tripDate = picked);
  }

  Future pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => tripTime = picked);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة رحلة")),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          TextField(controller: fromController, decoration: const InputDecoration(labelText: "من")),
          TextField(controller: toController, decoration: const InputDecoration(labelText: "إلى")),
          DropdownButtonFormField<String>(
            value: tripType,
            hint: const Text("نوع الرحلة"),
            items: ["طوعية", "خاصة"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => tripType = val),
          ),
          DropdownButtonFormField<String>(
            value: vehicleType,
            hint: const Text("الوسيلة"),
            items: ["باص", "قطار", "سيارة", "هايس"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => vehicleType = val),
          ),
          TextField(controller: seatsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "عدد المقاعد")),
          TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "سعر المقعد")),
          TextField(controller: pickupController, decoration: const InputDecoration(labelText: "نقطة التجمع")),
          TextField(controller: noteController, decoration: const InputDecoration(labelText: "ملاحظة")),
          ElevatedButton(onPressed: pickDate, child: Text(tripDate == null ? "اختيار التاريخ" : tripDate.toString().split(" ")[0])),
          ElevatedButton(onPressed: pickTime, child: Text(tripTime == null ? "اختيار الوقت" : tripTime!.format(context))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: isLoading ? null : publishTrip, child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("نشر الرحلة")),
        ],
      ),
    );
  }
}