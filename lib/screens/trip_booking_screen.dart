import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../utils/app_constants.dart';
import '../utils/user_session.dart';

class TripBookingScreen extends StatefulWidget {
  final Map trip;

  const TripBookingScreen({super.key, required this.trip});

  @override
  State<TripBookingScreen> createState() => _TripBookingScreenState();
}

class _TripBookingScreenState extends State<TripBookingScreen> {
  List<int> selectedSeats = [];
  List<Map<String, dynamic>> passengers = [];

  final picker = ImagePicker();
  bool isLoading = false;

  int bookedSeats = 0;

  @override
  void initState() {
    super.initState();

    /// 🔥 توحيد الـ id
    widget.trip["id"] ??= widget.trip["tripId"];

    bookedSeats = widget.trip["bookedSeats"] ?? 0;
  }

  void toggleSeat(int index) {
    if (index < bookedSeats) {
      showMsg("المقعد محجوز مسبقاً ❌");
      return;
    }

    setState(() {
      if (selectedSeats.contains(index)) {
        selectedSeats.remove(index);
      } else {
        selectedSeats.add(index);
      }
    });
  }

  void createPassengers() {
    passengers = selectedSeats.map((seat) {
      return {
        "seat": seat + 1,
        "name": "",
        "phone": "",
        "destination": "",
        "document": null,
      };
    }).toList();

    setState(() {});
  }

  Future pickImage(int i) async {
    try {
      final picked =
          await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() {
          passengers[i]["document"] = File(picked.path);
        });
      }
    } catch (e) {
      showMsg("فشل اختيار الصورة ❌");
    }
  }

  bool validate() {
    if (selectedSeats.isEmpty) return false;

    for (var p in passengers) {
      if ((p["name"] ?? "").toString().trim().isEmpty ||
          (p["phone"] ?? "").toString().trim().isEmpty ||
          (p["destination"] ?? "").toString().trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  void showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future sendBookingRequest() async {
    if (isLoading) return;

    if (widget.trip["id"] == null) {
      showMsg("خطأ في الرحلة ❌");
      return;
    }

    if (!validate()) {
      showMsg("أكمل بيانات الركاب ❌");
      return;
    }

    int totalSeats = widget.trip["totalSeats"] ?? 0;

    if (bookedSeats + selectedSeats.length > totalSeats) {
      showMsg("المقاعد غير كافية ❌");
      return;
    }

    int price = widget.trip["price"] ?? 0;
    int seatsCount = selectedSeats.length;

    int tripCost = price * seatsCount;

    int commission = AppConstants.enableUserCommission
        ? seatsCount * AppConstants.userCommissionPerSeat
        : 0;

    int totalCost = tripCost + commission;

    bool confirm = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("تأكيد الحجز"),
            content: Text("الإجمالي: $totalCost كريدت"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("تأكيد"),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() => isLoading = true);

    try {
      File? file;

      for (var p in passengers) {
        if (p["document"] != null &&
            p["document"] is File &&
            (p["document"] as File).existsSync()) {
          file = p["document"];
          break;
        }
      }

      /// 🔥 استخدام API الموحد
      final response = await ApiService.postWithFile(
        "/trips/book",
        {
          "trip_id": widget.trip["id"],
          "user_id": UserSession.userId ?? "",
          "wallet_id": UserSession.walletId ?? "",
          "seats": selectedSeats,
          "passengers": passengers,
          "total": totalCost,
        },
        file: file,
      );

      if (response["success"] == true) {
        showMsg("تم الحجز بنجاح ✅");

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        showMsg(response["message"] ?? "فشل الحجز ❌");
      }
    } catch (e) {
      showMsg("خطأ في السيرفر ❌");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalSeats = widget.trip["totalSeats"] ?? 12;

    return Scaffold(
      appBar: AppBar(
        title: const Text("حجز المقاعد"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(totalSeats, (index) {
                final isSelected = selectedSeats.contains(index);
                final isBooked = index < bookedSeats;

                return GestureDetector(
                  onTap: () => toggleSeat(index),
                  child: Container(
                    width: 55,
                    height: 55,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isBooked
                          ? Colors.red
                          : isSelected
                              ? Colors.green
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (selectedSeats.isEmpty) {
                  showMsg("اختر مقاعد أولاً");
                  return;
                }
                createPassengers();
              },
              child: const Text("إدخال بيانات الركاب"),
            ),

            const SizedBox(height: 20),

            if (passengers.isNotEmpty)
              Column(
                children: List.generate(passengers.length, (i) {
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text("راكب رقم ${i + 1}"),

                          TextField(
                            decoration: const InputDecoration(
                                labelText: "الاسم"),
                            onChanged: (v) =>
                                passengers[i]["name"] = v,
                          ),

                          TextField(
                            decoration: const InputDecoration(
                                labelText: "الهاتف"),
                            onChanged: (v) =>
                                passengers[i]["phone"] = v,
                          ),

                          TextField(
                            decoration: const InputDecoration(
                                labelText: "الوجهة"),
                            onChanged: (v) =>
                                passengers[i]["destination"] = v,
                          ),

                          const SizedBox(height: 10),

                          ElevatedButton(
                            onPressed: () => pickImage(i),
                            child: const Text("رفع مستند"),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

            const SizedBox(height: 20),

            if (passengers.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : sendBookingRequest,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("تأكيد الحجز"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}