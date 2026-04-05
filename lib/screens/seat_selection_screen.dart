import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/wallet_service.dart';
import '../utils/user_session.dart';
import 'chat_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final String tripId;

  const SeatSelectionScreen({
    Key? key,
    required this.trip,
    required this.tripId,
  }) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  List<int> selectedSeats = [];

  final Map<int, TextEditingController> nameControllers = {};
  final Map<int, TextEditingController> phoneControllers = {};
  final Map<int, TextEditingController> toControllers = {};

  late List<Map<String, dynamic>> seats;

  bool isLoading = false;

  final Color primary = const Color(0xFF6A1B9A);
  final Color dark = const Color(0xFF1E1E2C);
  final Color vehicleBg = const Color(0xFF151520);
  final Color lightCard = const Color(0xFF2C2C3C);

  @override
  void initState() {
    super.initState();

    seats = List<Map<String, dynamic>>.from(
      (widget.trip["seats"] ?? [])
          .map((e) => Map<String, dynamic>.from(e)),
    );
  }

  bool isBooked(int seatNumber) {
    try {
      final seatData = seats.firstWhere(
        (s) => s["seat"] == seatNumber,
        orElse: () => {"booked": false},
      );
      return seatData["booked"] == true;
    } catch (e) {
      return false;
    }
  }

  void selectSeat(int seatNumber) {
    if (isBooked(seatNumber)) return;

    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);

        nameControllers[seatNumber]?.dispose();
        phoneControllers[seatNumber]?.dispose();
        toControllers[seatNumber]?.dispose();

        nameControllers.remove(seatNumber);
        phoneControllers.remove(seatNumber);
        toControllers.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);

        nameControllers[seatNumber] = TextEditingController();
        phoneControllers[seatNumber] = TextEditingController();
        toControllers[seatNumber] = TextEditingController();
      }
    });
  }

  Color seatColor(int seatNumber) {
    if (isBooked(seatNumber)) return Colors.red;
    if (selectedSeats.contains(seatNumber)) return primary;
    return Colors.grey.shade700;
  }

  Widget buildSeat(int seatNumber) {
    bool selected = selectedSeats.contains(seatNumber);
    bool booked = isBooked(seatNumber);

    Color color = seatColor(seatNumber);

    return GestureDetector(
      onTap: () => selectSeat(seatNumber),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: selected
            ? (Matrix4.identity()..scale(1.1))
            : Matrix4.identity(),
        margin: const EdgeInsets.all(6),
        child: Opacity(
          opacity: booked ? 0.6 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 50,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: booked
                    ? const Icon(Icons.close,
                        size: 16, color: Colors.white)
                    : Text(
                        "$seatNumber",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget driverWidget() {
    return Column(
      children: const [
        Icon(Icons.drive_eta, color: Colors.orange, size: 40),
        SizedBox(height: 5),
        Text("السائق", style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget vehicleContainer(List<Widget> seatsLayout) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: vehicleBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(children: seatsLayout),
    );
  }

  List<Widget> buildBusSeats(int totalSeats) {
    List<Widget> rows = [];
    int seat = 1;

    rows.add(driverWidget());

    while (seat <= totalSeats) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildSeat(seat),
          buildSeat(seat + 1),
          const SizedBox(width: 20),
          if (seat + 2 <= totalSeats) buildSeat(seat + 2),
          if (seat + 3 <= totalSeats) buildSeat(seat + 3),
        ],
      ));
      seat += 4;
    }

    return rows;
  }

  List<Widget> buildTaxiSeats(int totalSeats) {
    List<Widget> rows = [];
    int seat = 1;

    rows.add(driverWidget());

    while (seat <= totalSeats) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildSeat(seat),
          const SizedBox(width: 40),
          if (seat + 1 <= totalSeats) buildSeat(seat + 1),
        ],
      ));
      seat += 2;
    }

    return rows;
  }

  List<Widget> buildMicrobusSeats(int totalSeats) {
    List<Widget> rows = [];
    int seat = 1;

    rows.add(driverWidget());

    if (seat <= totalSeats) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildSeat(seat),
          const SizedBox(width: 40),
          const Icon(Icons.door_front_door, color: Colors.white54),
        ],
      ));
      seat++;
    }

    while (seat + 2 <= totalSeats - 1) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildSeat(seat),
          buildSeat(seat + 1),
          const SizedBox(width: 25),
          buildSeat(seat + 2),
        ],
      ));
      seat += 3;
    }

    if (seat <= totalSeats) {
      rows.add(Center(child: buildSeat(seat)));
    }

    return rows;
  }

  List<Widget> buildSeatsLayout(String type, int totalSeats) {
    switch (type) {
      case "taxi":
        return buildTaxiSeats(totalSeats);
      case "microbus":
        return buildMicrobusSeats(totalSeats);
      default:
        return buildBusSeats(totalSeats);
    }
  }

  double calculateTotal() {
    double price = (widget.trip["price"] ?? 0).toDouble();
    return price * selectedSeats.length;
  }

  Future<void> confirmBooking() async {
    if (selectedSeats.isEmpty) return;

    setState(() => isLoading = true);

    try {
      double total = calculateTotal();
      String userId = UserSession.userId;

      double balance = (await WalletService.getBalance(userId)).toDouble();

      if (balance < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الرصيد غير كافي ❌")),
        );
        setState(() => isLoading = false);
        return;
      }

      await WalletService.deduct(
        userId: userId,
        amount: total,
      );

      List passengers = selectedSeats.map((seat) {
        return {
          "seat": seat,
          "name": nameControllers[seat]?.text ?? "",
          "phone": phoneControllers[seat]?.text ?? "",
          "to": toControllers[seat]?.text ?? "",
        };
      }).toList();

      Map<String, dynamic> response = {"bookingId": "temp_id"};

      try {
        response = await ApiService.bookTrip(
          tripId: widget.tripId,
          seats: selectedSeats,
          passengers: passengers,
        );
      } catch (e) {}

      try {
        await ApiService.sendMessage(
          tripId: widget.tripId,
          message: "📩 طلب حجز جديد (${selectedSeats.length} مقاعد)",
        );
      } catch (e) {}

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("تم إرسال طلب الحجز بنجاح ✅"),
        ),
      );

      // ✅ التعديل هنا فقط
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: response["bookingId"], // ✅ بدل bookingId
            userType: "user", // ✅ قيمة ثابتة
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final seatsLayout = buildSeatsLayout(
      widget.trip["vehicleType"] ?? "bus",
      widget.trip["totalSeats"] ?? 0,
    );

    return Scaffold(
      backgroundColor: dark,
      appBar: AppBar(
        title: const Text("اختيار المقاعد"),
        backgroundColor: primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                vehicleContainer(seatsLayout),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: isLoading ? null : confirmBooking,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("تأكيد الحجز"),
            ),
          ),
        ],
      ),
    );
  }
}