import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CompanyTripsViewScreen extends StatefulWidget {
  const CompanyTripsViewScreen({super.key});

  @override
  State<CompanyTripsViewScreen> createState() => _CompanyTripsViewScreenState();
}

class _CompanyTripsViewScreenState extends State<CompanyTripsViewScreen> {

  final TextEditingController tripsCodeController = TextEditingController();

  List trips = [];
  bool isLoading = false;
  bool isError = false;
  bool showTrips = false;

  /// 🔍 البحث عن الرحلات باستخدام API SERVICE
  Future<void> searchTrips() async {

    final code = tripsCodeController.text.trim();

    if (code.isEmpty) {
      showMsg("ادخل كود الرحلات");
      return;
    }

    setState(() {
      isLoading = true;
      isError = false;
      showTrips = true;
      trips = [];
    });

    try {

      final data = await ApiService.getTrips(code);

      if (data["success"] == true) {

        setState(() {
          trips = data["trips"] ?? [];
          isLoading = false;
        });

      } else {

        setState(() {
          isError = true;
          isLoading = false;
        });

      }

    } catch (e) {

      setState(() {
        isError = true;
        isLoading = false;
      });

      showMsg("خطأ في الاتصال ❌");

    }
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
        title: const Text("عرض رحلات الشركة"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: tripsCodeController,
              decoration: const InputDecoration(
                labelText: "ادخل كود رحلات الشركة",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: searchTrips,
                child: const Text(
                  "عرض الرحلات",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (showTrips)
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())

                    : isError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                const Text("حدث خطأ ❌"),

                                const SizedBox(height: 10),

                                ElevatedButton(
                                  onPressed: searchTrips,
                                  child: const Text("إعادة المحاولة"),
                                )

                              ],
                            ),
                          )

                        : trips.isEmpty
                            ? const Center(
                                child: Text(
                                  "لا توجد رحلات بهذا الكود",
                                  style: TextStyle(fontSize: 18),
                                ),
                              )

                            : RefreshIndicator(
                                onRefresh: searchTrips,
                                child: ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: trips.length,
                                  itemBuilder: (context, index) {

                                    final item = trips[index];

                                    final from = item["from"] ?? "-";
                                    final to = item["to"] ?? "-";
                                    final date = item["date"] ?? "-";
                                    final time = item["time"] ?? "-";
                                    final seats = item["seats"] ?? 0;

                                    return Card(
                                      margin: const EdgeInsets.all(10),
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.directions_bus,
                                          color: Colors.blue,
                                          size: 35,
                                        ),

                                        title: Text(
                                          "$from ➜ $to",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            const SizedBox(height: 5),
                                            Text("📅 التاريخ: $date"),
                                            Text("⏰ الوقت: $time"),
                                            Text("💺 المقاعد: $seats"),

                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
          ],
        ),
      ),
    );
  }
}