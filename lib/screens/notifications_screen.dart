import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/ticket_service.dart';
import '../utils/user_session.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  List<TicketModel> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {

    try {
      final userId = await UserSession.safeUserId();

      if (userId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final data = await TicketService.getTickets(userId);

      tickets = data;

    } catch (e) {
      print("❌ Notifications load error: $e");
      tickets = [];
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getTitle(TicketModel ticket) {
    switch (ticket.type) {
      case "trip":
        return "🎫 حجز رحلة";
      case "deposit":
        return "💰 طلب إيداع";
      case "receipt":
        return "✅ تم الإيداع";
      default:
        return "إشعار";
    }
  }

  String getSubtitle(TicketModel ticket) {
    if (ticket.type == "trip") {
      return "${ticket.from ?? "-"} → ${ticket.to ?? "-"} | ${ticket.passengerName ?? "-"}";
    } else if (ticket.type == "deposit") {
      return "طلب إيداع: ${ticket.amount ?? 0} كريت";
    } else if (ticket.type == "receipt") {
      return "تم إضافة ${ticket.amount ?? 0} إلى محفظتك";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (tickets.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("الإشعارات")),
        body: const Center(child: Text("لا توجد إشعارات")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("الإشعارات"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {

              final userId = await UserSession.safeUserId();

              if (userId != null) {
                await TicketService.markAllAsRead(userId);
                await _loadNotifications();
              }
            },
          )
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {

            final ticket = tickets[index];

            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              color: ticket.isRead == true
                  ? Colors.white
                  : Colors.grey.shade200,

              child: ListTile(
                leading: Icon(
                  ticket.isRead == true
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                  color: ticket.isRead == true
                      ? Colors.grey
                      : Colors.blue,
                ),

                title: Text(getTitle(ticket)),
                subtitle: Text(getSubtitle(ticket)),

                trailing: ticket.isRead == true
                    ? null
                    : const Icon(Icons.circle,
                        color: Colors.red, size: 10),

                onTap: () async {

                  if (ticket.id != null) {
                    await TicketService.markAsRead(
                      ticket.id.toString(),
                    );
                  }

                  setState(() {
                    ticket.isRead = true;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}