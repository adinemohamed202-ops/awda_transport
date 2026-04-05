import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/ticket_service.dart';
import '../models/ticket_model.dart';

class AdminTopUpScreen extends StatefulWidget {
  const AdminTopUpScreen({super.key});

  @override
  State<AdminTopUpScreen> createState() => _AdminTopUpScreenState();
}

class _AdminTopUpScreenState extends State<AdminTopUpScreen> {
  String searchCode = "";
  final player = AudioPlayer();
  int lastCount = 0;

  List<TicketModel> deposits = [];
  List<TicketModel> issues = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  /// 📥 جلب الطلبات
  Future<void> fetchRequests() async {
    final data = await TicketService.getAllDeposits();

    List<TicketModel> d = [];
    List<TicketModel> i = [];

    for (var item in data) {
      if (item.type == "issue") {
        i.add(item);
      } else {
        d.add(item);
      }
    }

    setState(() {
      deposits = d;
      issues = i;
      loading = false;
    });

    if (data.length > lastCount) {
      playSound();
      showAlert();
      lastCount = data.length;
    }
  }

  /// 🔊 صوت
  Future playSound() async {
    await player.play(AssetSource('sounds/notification.mp3'));
  }

  /// 🔔 إشعار
  void showAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🔔 طلب جديد")),
    );
  }

  /// 📋 نسخ
  void copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showMsg("تم النسخ");
  }

  /// 👁️ عرض صورة
  void showImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }

  /// ✅ موافقة
  Future approveRequest(String id) async {
    final ok = await TicketService.approveDeposit(depositId: id);

    showMsg(ok ? "تمت الموافقة ✅" : "فشل ❌");

    if (ok) fetchRequests();
  }

  /// ❌ رفض
  Future rejectRequest(String id) async {
    final ok = await TicketService.rejectDeposit(depositId: id);

    showMsg(ok ? "تم الرفض ❌" : "فشل ❌");

    if (ok) fetchRequests();
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /// 📦 Widget موحد
  Widget buildList(List<TicketModel> list, {bool isIssue = false}) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return const Center(child: Text("لا توجد بيانات"));
    }

    return RefreshIndicator(
      onRefresh: fetchRequests,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) {
          final data = list[i];

          if (searchCode.isNotEmpty &&
              !(data.code ?? "").contains(searchCode)) {
            return const SizedBox();
          }

          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("👤 ${data.userId ?? "-"}"),
                  Text("💰 ${data.amount ?? 0}"),
                  Text("🔑 ${data.code ?? "-"}"),

                  if (data.message != null)
                    Text("📝 ${data.message}"),

                  const SizedBox(height: 10),

                  if (data.receiptImage != null)
                    GestureDetector(
                      onTap: () => showImage(data.receiptImage!),
                      child: Image.network(
                        data.receiptImage!,
                        height: 120,
                      ),
                    ),

                  if (!isIssue && data.status == "pending")
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                approveRequest(data.id!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text("موافقة"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                rejectRequest(data.id!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("رفض"),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("إدارة الإيداع"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "الطلبات"),
              Tab(text: "المشاكل"),
            ],
          ),
        ),
        body: Column(
          children: [

            /// 🔍 بحث
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "ابحث بالكود",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  setState(() {
                    searchCode = v;
                  });
                },
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  buildList(deposits),
                  buildList(issues, isIssue: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}