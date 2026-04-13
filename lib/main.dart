import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'services/notification_service.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/tickets_screen.dart';
import 'utils/user_session.dart';

final AudioPlayer player = AudioPlayer();
final Set<String> notifiedDeposits = {};
StreamSubscription? depositsSub;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserSession.loadUser();
  await NotificationService.init();

  runApp(MyApp());
}

/// 🔔 مراقبة الإيداعات (API polling)
void listenToDeposits() {
  depositsSub?.cancel();

  depositsSub = Stream.periodic(const Duration(seconds: 5)).listen((_) async {
    try {

      /// 🔥 إضافة: تأكد من userId
      final userId = await UserSession.safeUserId();
      if (userId == null) return;

      final response = await ApiService.post(
        "/deposits",
        {
          "user_id": userId,
        },
      );

      if (response["data"] == null) return;

      for (var item in response["data"]) {
        final id = item["id"].toString();

        if (notifiedDeposits.contains(id)) continue;

        if (item["status"] == "pending") {
          notifiedDeposits.add(id);

          try {
            await player.play(AssetSource("sounds/notification.mp3"));
          } catch (e) {
            debugPrint("⚠️ صوت فشل: $e");
          }

          debugPrint("🔔 طلب شحن جديد!");
        }
      }
    } catch (e) {
      debugPrint("🔥 API error: $e");
    }
  });
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    /// 🔥 إضافة: تأكد المستخدم قبل بدء الاستماع
    if (UserSession.isLoggedIn) {
      listenToDeposits();
    }
  }

  @override
  void dispose() {
    depositsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Awda App',

      initialRoute: UserSession.isLoggedIn ? '/home' : '/login',

      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/wallet': (context) => WalletScreen(),
        '/tickets': (context) => TicketsScreen(),
      },

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        primaryColor: const Color(0xFF6A00FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A00FF),
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}