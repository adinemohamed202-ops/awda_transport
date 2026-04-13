import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userType;

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
      final data = await ApiService.get("/chat/${widget.chatId}");

      if (!mounted) return;

      if (data["success"] == true) {
        setState(() {
          messages = data["messages"] ?? [];
          bookingStatus = data["status"] ?? "pending";
          ticketCreated = data["ticketCreated"] ?? false;
          isSupport = data["type"] == "support" || isSupport;
          loading = false;
        });

        scrollToBottom();
      } else {
        setState(() => loading = false);
        showMsg(data["message"] ?? "فشل تحميل الرسائل ❌");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMsg("خطأ في الاتصال ❌");
    }
  }

  /// 🔥 FIX: توحيد الإرسال مع ApiService
  Future<void> sendText() async {
    if (messageController.text.trim().isEmpty) return;

    try {
      final res = await ApiService.sendMessage(
        chatId: widget.chatId,
        message: messageController.text.trim(),
      );

      if (res["success"] == true) {
        messageController.clear();
        fetchMessages();
      } else {
        showMsg(res["message"] ?? "فشل الإرسال ❌");
      }
    } catch (e) {
      showMsg("فشل الإرسال ❌");
    }
  }

  Future<void> sendImage() async {
    try {
      final image =
          await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      File file = File(image.path);

      final res = await ApiService.postWithFile(
        "/chat/send-image",
        {
          "chatId": widget.chatId,
          "sender": widget.userType,
        },
        file: file,
      );

      if (res["success"] == true) {
        fetchMessages();
      } else {
        showMsg(res["message"] ?? "فشل رفع الصورة ❌");
      }
    } catch (e) {
      showMsg("فشل رفع الصورة ❌");
    }
  }

  Future<void> createTicket({bool temporary = false}) async {
    try {
      final ticketRes = await ApiService.post(
        "/chat/ticket",
        {
          "chatId": widget.chatId,
          "temporary": temporary,
          "sender": widget.userType,
        },
      );

      if (ticketRes["success"] != true) {
        showMsg(ticketRes["message"] ?? "فشل إنشاء التذكرة ❌");
        return;
      }

      await ApiService.post("/wallet/confirm-payment", {
        "chatId": widget.chatId,
      });

      await ApiService.sendMessage(
        chatId: widget.chatId,
        message: "🎫 تم إنشاء التذكرة وتأكيد الدفع",
      );

      if (!mounted) return;

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
            style: ElevatedButton.styleFrom(
                backgroundColor: primary),
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
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter:
                ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
    bool isMe = (data["sender"] ?? "") == widget.userType;

    switch (data["type"]) {
      case "image":
        if (data["imageUrl"] == null) return const SizedBox();
        return bubble(
          Image.network(data["imageUrl"], width: 200),
          isMe,
        );

      case "ticket":
      case "temporary_ticket":
        return bubble(
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                data["type"] == "ticket"
                    ? "🎫 تذكرة"
                    : "🟡 تذكرة مؤقتة",
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold),
              ),
              Text("📍 ${data["from"] ?? ""} ➜ ${data["to"] ?? ""}",
                  style:
                      const TextStyle(color: Colors.white)),
              Text("💺 ${data["seats"] ?? ""}",
                  style:
                      const TextStyle(color: Colors.white)),
              Text("💰 ${data["price"] ?? ""}",
                  style:
                      const TextStyle(color: Colors.white)),
            ],
          ),
          false,
        );

      default:
        return bubble(
          Text(data["text"] ?? "",
              style:
                  const TextStyle(color: Colors.white)),
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
    if (!mounted) return;
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
                ? const Center(
                    child: CircularProgressIndicator())
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image,
                      color: Colors.white),
                  onPressed: sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(
                        color: Colors.white),
                    decoration:
                        const InputDecoration(
                      hintText: "اكتب رسالة...",
                      hintStyle: TextStyle(
                          color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon:
                      Icon(Icons.send, color: primary),
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