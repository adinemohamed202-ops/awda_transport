import 'package:flutter/material.dart';  
import '../services/api_service.dart';  
import '../services/wallet_service.dart';  
import '../utils/user_session.dart';  
import 'chat_screen.dart';  
  
class SeatSelectionScreen extends StatefulWidget {  
  final Map<String, dynamic> trip;  
  final String? tripId;  
  
  const SeatSelectionScreen({  
    Key? key,  
    required this.trip,  
    this.tripId,  
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
  
  String get tripIdSafe {  
    final idFromTrip = widget.trip["id"]?.toString();  
    final idFromParam = widget.tripId;  
  
    if (idFromTrip != null && idFromTrip.isNotEmpty) return idFromTrip;  
    if (idFromParam != null && idFromParam.isNotEmpty) return idFromParam;  
  
    return "";  
  }  
  
  @override  
  void initState() {  
    super.initState();  
  
    final rawSeats = widget.trip["seats"];  
  
    if (rawSeats is List) {  
      seats = List<Map<String, dynamic>>.from(  
        rawSeats.map((e) => Map<String, dynamic>.from(e)),  
      );  
    } else {  
      seats = [];  
    }  
  }  
  
  bool isBooked(int seatNumber) {  
    final seatData = seats.firstWhere(  
      (s) => s["seat"] == seatNumber,  
      orElse: () => {"booked": false},  
    );  
    return seatData["booked"] == true;  
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
  
  double calculateTotal() {  
    double price = double.tryParse(widget.trip["price"]?.toString() ?? "0") ?? 0;  
    return price * selectedSeats.length;  
  }  
  
  bool validatePassengers() {  
    for (var seat in selectedSeats) {  
      if ((nameControllers[seat]?.text ?? "").isEmpty ||  
          (phoneControllers[seat]?.text ?? "").isEmpty) {  
        return false;  
      }  
    }  
    return true;  
  }  
  
  Future<void> confirmBooking() async {  
    if (selectedSeats.isEmpty) return;  
  
    if (tripIdSafe.isEmpty) {  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text("Trip ID مفقود ❌")),  
      );  
      return;  
    }  
  
    if (UserSession.userId.isEmpty) {  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text("يجب تسجيل الدخول أولاً ❌")),  
      );  
      return;  
    }  
  
    if (!validatePassengers()) {  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text("أدخل بيانات الركاب كاملة ❌")),  
      );  
      return;  
    }  
  
    setState(() => isLoading = true);  
  
    try {  
      double total = calculateTotal();  
      String userId = UserSession.userId;  
  
      double balance = double.tryParse(  
            (await WalletService.getBalance(userId)).toString(),  
          ) ?? 0;  
  
      if (balance < total) {  
        ScaffoldMessenger.of(context).showSnackBar(  
          const SnackBar(content: Text("الرصيد غير كافي ❌")),  
        );  
        setState(() => isLoading = false);  
        return;  
      }  
  
      List passengers = selectedSeats.map((seat) {  
        return {  
          "seat": seat,  
          "name": nameControllers[seat]?.text.trim(),  
          "phone": phoneControllers[seat]?.text.trim(),  
          "to": toControllers[seat]?.text.trim(),  
        };  
      }).toList();  
  
      final response = await ApiService.bookTrip(  
        tripId: tripIdSafe,  
        seats: selectedSeats,  
        passengers: passengers,  
      );  
  
      if (response["success"] == false) {  
        throw response["message"];  
      }  
  
      await WalletService.deduct(  
        userId: userId,  
        amount: total.toInt(), // ✅ إصلاح هنا
      );  
  
      try {  
        await ApiService.sendMessage(  
          tripId: tripIdSafe,  
          message: "📩 طلب حجز (${selectedSeats.length} مقاعد)",  
        );  
      } catch (_) {}  
  
      if (!mounted) return;  
  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(  
          backgroundColor: Colors.green,  
          content: Text("تم الحجز بنجاح ✅"),  
        ),  
      );  
  
      Navigator.pushReplacement(  
        context,  
        MaterialPageRoute(  
          builder: (_) => ChatScreen(  
            chatId: response["bookingId"]?.toString() ?? "",  
            userType: "user",  
          ),  
        ),  
      );  
    } catch (e) {  
      if (!mounted) return;  
  
      ScaffoldMessenger.of(context).showSnackBar(  
        SnackBar(content: Text("خطأ: $e")),  
      );  
    }  
  
    if (mounted) {  
      setState(() => isLoading = false);  
    }  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    final List<Widget> seatsLayout = []; // ✅ إصلاح النوع هنا  
  
    int totalSeats = int.tryParse(widget.trip["totalSeats"]?.toString() ?? "0") ?? 0;  
  
    for (int i = 1; i <= totalSeats; i++) {  
      seatsLayout.add(  
        GestureDetector(  
          onTap: () => selectSeat(i),  
          child: Container(  
            margin: const EdgeInsets.all(6),  
            width: 50,  
            height: 50,  
            alignment: Alignment.center,  
            decoration: BoxDecoration(  
              color: selectedSeats.contains(i)  
                  ? primary  
                  : (isBooked(i) ? Colors.red : Colors.grey),  
              borderRadius: BorderRadius.circular(10),  
            ),  
            child: Text("$i",  
                style: const TextStyle(color: Colors.white)),  
          ),  
        ),  
      );  
    }  
  
    return Scaffold(  
      backgroundColor: dark,  
      appBar: AppBar(  
        title: const Text("اختيار المقاعد"),  
        backgroundColor: primary,  
      ),  
      body: Column(  
        children: [  
          Expanded(  
            child: GridView.count(  
              crossAxisCount: 4,  
              children: seatsLayout,  
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