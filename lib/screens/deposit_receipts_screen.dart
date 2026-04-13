import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DepositReceiptsScreen extends StatefulWidget {
  const DepositReceiptsScreen({super.key});

  @override
  State<DepositReceiptsScreen> createState() =>
      _DepositReceiptsScreenState();
}

class _DepositReceiptsScreenState
    extends State<DepositReceiptsScreen> {

  List tickets = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      DateTime d = DateTime.parse(date);
      return "${d.year}-${d.month}-${d.day}  ${d.hour}:${d.minute}";
    } catch (e) {
      return date;
    }
  }

  /// 🔥 جلب التذاكر باستخدام API SERVICE
  Future<void> fetchTickets() async {

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {

      final data = await ApiService.getTickets();

      if (data["success"] == true) {

        /// 🔥 فلترة الإيداع فقط
        List all = data["tickets"] ?? [];

        List deposits = all.where((t) =>
            t["type"] == "deposit" || t["type"] == "receipt"
        ).toList();

        setState(() {
          tickets = deposits;
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
        title: const Text("إيصالات الإيداع"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text("حدث خطأ ❌"),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: fetchTickets,
                        child: const Text("إعادة المحاولة"),
                      )

                    ],
                  ),
                )

              : tickets.isEmpty
                  ? const Center(child: Text("لا توجد عمليات إيداع"))

                  : RefreshIndicator(
                      onRefresh: fetchTickets,
                      child: ListView.builder(
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {

                          final ticket = tickets[index];

                          final isDone =
                              ticket["type"] == "receipt";

                          final amount = ticket["amount"] ?? 0;
                          final date = ticket["createdAt"];

                          return Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(15),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [

                                    Text(
                                      isDone
                                          ? "✅ تم الإيداع"
                                          : "⏳ قيد المراجعة",
                                      style: TextStyle(
                                        color: isDone
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      "$amount كريت",
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "🕒 ${formatDate(date)}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),

                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}