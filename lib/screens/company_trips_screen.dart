import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CompanyTripsScreen extends StatefulWidget {
  final String companyCode;
  final String tripsCode;

  const CompanyTripsScreen({
    super.key,
    required this.companyCode,
    required this.tripsCode,
  });

  @override
  State<CompanyTripsScreen> createState() => _CompanyTripsScreenState();
}

class _CompanyTripsScreenState extends State<CompanyTripsScreen> {
  List<Map<String, dynamic>> trips = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  /// 🔥 جلب الرحلات من ApiService
  Future<void> fetchTrips() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final data = await ApiService.getCompanyTrips(widget.companyCode);

      if (!mounted) return;

      final list = data["trips"] ?? data["data"] ?? [];

      setState(() {
        trips = List<Map<String, dynamic>>.from(list);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isError = true;
        isLoading = false;
      });

      showMsg("فشل تحميل الرحلات ❌");
    }
  }

  void showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("عرض الرحلات"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                          onPressed: fetchTrips,
                          child: const Text("إعادة المحاولة"),
                        )
                      ],
                    ),
                  )
                : trips.isEmpty
                    ? const Center(child: Text("لا توجد رحلات"))
                    : RefreshIndicator(
                        onRefresh: fetchTrips,
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
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const Icon(Icons.directions_bus),
                                title: Text("$from ➜ $to"),
                                subtitle: Text("📅 $date   ⏰ $time"),
                                trailing: Text(
                                  "💺 $seats",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}