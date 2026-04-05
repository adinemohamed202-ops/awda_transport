// نفس الاستيرادات بدون تغيير
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/ticket_service.dart';
import '../models/ticket_model.dart';
import '../utils/user_session.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({Key? key}) : super(key: key);

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  List<TicketModel> tickets = [];
  bool isLoading = true;

  Timer? pollingTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();

    pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadTickets(silent: true);
      }
    });
  }

  Future<void> _loadTickets({bool silent = false}) async {
    try {
      final data = await TicketService.getTickets(
        UserSession.userId!.toString(),
      );

      if (mounted) {
        setState(() {
          tickets = data;
          if (!silent) isLoading = false;
        });
      }

    } catch (_) {
      if (mounted) {
        setState(() {
          tickets = [];
          if (!silent) isLoading = false;
        });
      }
    }
  }

  /// 🔥 ألوان الحالة
  Color getStatusColor(String? status) {
    switch (status) {
      case "accepted":
      case "paid":
        return Colors.greenAccent;
      case "rejected":
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  /// 🔥 نص الحالة
  String getStatusText(String? status) {
    switch (status) {
      case "accepted":
        return "✅ مقبول";
      case "paid":
        return "💰 مدفوع";
      case "rejected":
        return "❌ مرفوض";
      default:
        return "⏳ قيد الانتظار";
    }
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Widget glassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05)
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("التذاكر"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white.withOpacity(0.3),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "🎫 الرحلات"),
            Tab(text: "💰 الإيداع"),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF1A237E)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            buildTrips(),
            buildDeposits(),
          ],
        ),
      ),
    );
  }

  /// 🎫 الرحلات (بدون تغيير كبير)
  Widget buildTrips() {
    final trips = tickets.where((t) => t.type == "trip").toList();

    if (trips.isEmpty) {
      return const Center(
        child: Text("لا توجد رحلات",
            style: TextStyle(color: Colors.white)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: trips.length,
        itemBuilder: (_, i) {

          final t = trips[i];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    getStatusText(t.status),
                    style: TextStyle(
                      color: getStatusColor(t.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${t.from ?? "-"} ➜ ${t.to ?? "-"}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),

                  const SizedBox(height: 4),

                  Text("💰 ${t.totalPrice ?? 0} كريت",
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  if (t.status == "accepted" && t.ticketNumber != null)
                    Center(
                      child: Column(
                        children: [
                          QrImageView(
                            data: t.ticketNumber!,
                            size: 130,
                            backgroundColor:
                                Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t.ticketNumber!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 💰 الإيداع (🔥 الجزء المهم)
  Widget buildDeposits() {

    final deposits = tickets
        .where((t) =>
            t.type == "deposit" || t.type == "receipt")
        .toList();

    if (deposits.isEmpty) {
      return const Center(
        child: Text("لا توجد عمليات إيداع",
            style: TextStyle(color: Colors.white)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: deposits.length,
        itemBuilder: (_, i) {

          final t = deposits[i];

          String statusText;
          Color statusColor;

          if (t.status == "rejected") {
            statusText = "❌ مرفوض";
            statusColor = Colors.redAccent;
          } else if (t.type == "receipt") {
            statusText = "✅ تم الإيداع";
            statusColor = Colors.greenAccent;
          } else {
            statusText = "⏳ قيد المراجعة";
            statusColor = Colors.orangeAccent;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "${t.amount ?? 0} كريت",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "🕒 ${t.createdAtFormatted}",
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}