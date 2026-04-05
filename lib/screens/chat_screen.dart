import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userType;

  // ✅ نخليهم اختياري
  final String? tripId;
  final String? bookingId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.userType,
    this.tripId,
    this.bookingId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker picker = ImagePicker();

  List messages = [];
  bool loading = true;

  String bookingStatus = "pending";
  bool ticketCreated = false;

  final String baseUrl = "http://192.168.1.3:3000/api";

  final Color primary = const Color(0xFF6C5CE7);
  final Color dark = const Color(0xFF0F172A);

  bool isSupport = false;

  @override
  void initState() {
    super.initState();

    if (widget.userType == "admin") {
      isSupport = true;
    }

    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/chat/${widget.chatId}"),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"]) {
        setState(() {
          messages = data["messages"];
          bookingStatus = data["status"] ?? "pending";
          ticketCreated = data["ticketCreated"] ?? false;
          isSupport = data["type"] == "support" || isSupport;
          loading = false;
        });

        scrollToBottom();
      } else {
        showMsg("فشل تحميل الرسائل ❌");
      }
    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
    }
  }

  Future<void> sendText() async {
    if (messageController.text.trim().isEmpty) return;

    try {
      await http.post(
        Uri.parse("$baseUrl/chat/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "chatId": widget.chatId,
          "type": "text",
          "text": messageController.text.trim(),
          "sender": widget.userType,
        }),
      );

      messageController.clear();
      fetchMessages();
    } catch (e) {
      showMsg("فشل الإرسال ❌");
    }
  }

  Future<void> sendImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File file = File(image.path);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/chat/send-image"),
      );

      request.fields["chatId"] = widget.chatId;
      request.fields["sender"] = widget.userType;

      request.files.add(
        await http.MultipartFile.fromPath("image", file.path),
      );

      await request.send();

      fetchMessages();
    } catch (e) {
      showMsg("فشل رفع الصورة ❌");
    }
  }

  Future<void> createTicket({bool temporary = false}) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/chat/ticket"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "chatId": widget.chatId,
          "temporary": temporary,
          "sender": widget.userType,
        }),
      );

      await http.post(
        Uri.parse("$baseUrl/wallet/confirm-payment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "chatId": widget.chatId,
        }),
      );

      await http.post(
        Uri.parse("$baseUrl/chat/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "chatId": widget.chatId,
          "type": "text",
          "text": "🎫 تم إنشاء التذكرة وتأكيد الدفع",
          "sender": "system",
        }),
      );

      setState(() {
        ticketCreated = true;
      });

      showMsg("تم إنشاء التذكرة بنجاح ✅");
      fetchMessages();
    } catch (e) {
      showMsg("فشل إنشاء التذكرة ❌");
    }
  }

  void showCreateTicketDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text("تأكيد", style: TextStyle(color: primary)),
        content: const Text(
          "هل استلمت المبلغ؟",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text("لا"),
            onPressed: () {
              Navigator.pop(context);
              createTicket(temporary: true);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            onPressed: () {
              Navigator.pop(context);
              createTicket(temporary: false);
            },
            child: const Text("نعم"),
          ),
        ],
      ),
    );
  }

  Widget bubble(Widget child, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe
                    ? primary.withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMessage(Map data) {
    bool isMe = data["sender"] == widget.userType;

    switch (data["type"]) {
      case "image":
        return bubble(
          Image.network(data["imageUrl"], width: 200),
          isMe,
        );

      case "ticket":
      case "temporary_ticket":
        return bubble(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["type"] == "ticket"
                    ? "🎫 تذكرة"
                    : "🟡 تذكرة مؤقتة",
                style: TextStyle(
                    color: primary, fontWeight: FontWeight.bold),
              ),
              Text("📍 ${data["from"]} ➜ ${data["to"]}",
                  style: const TextStyle(color: Colors.white)),
              Text("💺 ${data["seats"]}",
                  style: const TextStyle(color: Colors.white)),
              Text("💰 ${data["price"]}",
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
          false,
        );

      default:
        return bubble(
          Text(data["text"] ?? "",
              style: const TextStyle(color: Colors.white)),
          isMe,
        );
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isSupport ? "دعم فني" : "الدردشة"),
      ),
      floatingActionButton: (!isSupport &&
              widget.userType == "supervisor" &&
              bookingStatus == "accepted" &&
              !ticketCreated)
          ? FloatingActionButton(
              backgroundColor: primary,
              onPressed: showCreateTicketDialog,
              child: const Icon(Icons.confirmation_num),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchMessages,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        return buildMessage(messages[i]);
                      },
                    ),
                  ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.white),
                  onPressed: sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "اكتب رسالة...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: primary),
                  onPressed: sendText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}