import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  List allAds = [];
  List filteredAds = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  /// 🔥 جلب الرحلات باستخدام API SERVICE
  Future<void> fetchTrips() async {
    try {

      final data = await ApiService.getShippingTrips();

      setState(() {
        allAds = data ?? [];
        filteredAds = data ?? [];
        isLoading = false;
      });

    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  /// 🔍 بحث
  void searchAds() {
    final from = fromController.text.toLowerCase();
    final to = toController.text.toLowerCase();

    setState(() {
      filteredAds = allAds.where((ad) {
        return ad["from"].toString().toLowerCase().contains(from) &&
            ad["to"].toString().toLowerCase().contains(to);
      }).toList();
    });
  }

  /// 🔎 نافذة البحث
  void openSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("بحث"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fromController,
                decoration: const InputDecoration(labelText: "من"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: toController,
                decoration: const InputDecoration(labelText: "إلى"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                searchAds();
                Navigator.pop(context);
              },
              child: const Text("بحث"),
            ),
          ],
        );
      },
    );
  }

  /// 🔥 إنشاء الشات باستخدام API SERVICE
  Future<String?> createChat(String tripId) async {
    try {

      final data = await ApiService.createChat(tripId);

      if (data["success"] == true) {
        return data["chatId"];
      } else {
        showMsg(data["message"] ?? "فشل إنشاء الشات");
        return null;
      }

    } catch (e) {
      showMsg("خطأ في الاتصال");
      return null;
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الشحن"),
        actions: [
          IconButton(
            onPressed: openSearchDialog,
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          /// 🔍 بحث سريع
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (_) => searchAds(),
              decoration: InputDecoration(
                hintText: "ابحث عن رحلة...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          /// 📋 القائمة
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAds.isEmpty
                    ? const Center(child: Text("لا توجد إعلانات"))
                    : RefreshIndicator(
                        onRefresh: fetchTrips,
                        child: ListView.builder(
                          itemCount: filteredAds.length,
                          itemBuilder: (context, index) {
                            final ad = filteredAds[index];

                            return Card(
                              margin: const EdgeInsets.all(10),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ad["companyName"] ?? "",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text("المشرف: ${ad["supervisorName"]}"),
                                    Text("المكتب: ${ad["officeLocation"]}"),

                                    const SizedBox(height: 6),

                                    Text("${ad["from"]} ➜ ${ad["to"]}"),
                                    Text("المركبة: ${ad["vehicle"]}"),
                                    Text("السعر: ${ad["price"]} كريت"),

                                    const SizedBox(height: 10),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {

                                          final chatId =
                                              await createChat(ad["id"]);

                                          if (chatId == null) return;

                                          if (!mounted) return;

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChatScreen(
                                                chatId: chatId,
                                                userType: "user",
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text("تواصل"),
                                      ),
                                    ),
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
    );
  }
}