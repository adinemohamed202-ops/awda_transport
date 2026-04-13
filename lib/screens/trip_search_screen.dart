import 'package:flutter/material.dart';
import 'trip_results_screen.dart';

class TripSearchScreen extends StatefulWidget {
  final String tripType;
  final String category; // ✅ إضافة

  const TripSearchScreen({
    super.key,
    required this.tripType,
    required this.category, // ✅ إضافة
  });

  @override
  State<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> {
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  String? transportType;

  bool isSearchVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("بحث عن رحلة"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              setState(() {
                isSearchVisible = !isSearchVisible;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSearchVisible)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: fromController,
                      decoration: const InputDecoration(
                        labelText: "من",
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: toController,
                      decoration: const InputDecoration(
                        labelText: "إلى",
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "اختر وسيلة النقل",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    RadioListTile(
                      title: const Text("✈️ طائرة"),
                      value: "plane",
                      groupValue: transportType,
                      onChanged: (value) {
                        setState(() {
                          transportType = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text("🚌 باص"),
                      value: "bus",
                      groupValue: transportType,
                      onChanged: (value) {
                        setState(() {
                          transportType = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text("🚐 هايس"),
                      value: "hiace",
                      groupValue: transportType,
                      onChanged: (value) {
                        setState(() {
                          transportType = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text("🚗 سيارة خاصة"),
                      value: "car",
                      groupValue: transportType,
                      onChanged: (value) {
                        setState(() {
                          transportType = value.toString();
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (fromController.text.isEmpty ||
                              toController.text.isEmpty ||
                              transportType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("أدخل كل البيانات")),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripResultsScreen(
                                from: fromController.text,
                                to: toController.text,
                                transport: transportType!,
                                tripType: widget.tripType,
                                category: widget.category, // ✅ إضافة
                              ),
                            ),
                          );
                        },
                        child: const Text("ابحث عن رحلة"),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}