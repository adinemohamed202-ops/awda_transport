import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

// الشاشات
import 'trip_type_screen.dart';
import 'companies_screen.dart';
import 'supervisor_login_screen.dart';
import 'tickets_screen.dart';
import 'wallet_screen.dart';
import 'support_screen.dart';
import 'admin_login_screen.dart';
import 'notifications_screen.dart';

// utils + services
import '../utils/user_session.dart';
import '../services/wallet_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tapCount = 0;
  DateTime? _lastTap;

  bool isReady = false;

  String userName = "";
  int balance = 0;

  Timer? balanceTimer;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  @override
  void dispose() {
    balanceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initUser() async {
    await UserSession.loadUser();

    userName = UserSession.name.isEmpty ? "مستخدم" : UserSession.name;

    await _loadBalance();

    /// 🔥 شغل التايمر بعد التحميل فقط
    balanceTimer = Timer.periodic(const Duration(seconds: 15), (t) {
      if (UserSession.userId.isNotEmpty) {
        _loadBalance();
      }
    });

    if (!mounted) return;

    setState(() {
      isReady = true;
    });
  }

  Future<void> _loadBalance() async {
    try {
      /// 🔥 حماية من userId الفاضي
      if (UserSession.userId.isEmpty) return;

      final b = await WalletService.getBalance(
        UserSession.userId,
      );

      if (!mounted) return;

      setState(() {
        balance = b;
      });
    } catch (e) {
      print("❌ balance error: $e");
    }
  }

  void _handleTap() {
    final now = DateTime.now();

    if (_lastTap == null ||
        now.difference(_lastTap!) > const Duration(seconds: 2)) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTap = now;
  }

  void _handleLongPress() {
    if (_tapCount >= 4) {
      _tapCount = 0;

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminLoginScreen(),
        ),
      );
    }
  }

  Widget _buildNotificationIcon() {
    return IconButton(
      icon: const Icon(Icons.notifications, color: Colors.white),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
          ),
        );
      },
    );
  }

  /// 👤 كرت المستخدم
  Widget _buildUserCard() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalletScreen()),
        );

        /// 🔥 تحديث بعد الرجوع
        _loadBalance();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "👋 مرحباً، $userName",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "💰 رصيدك: $balance كريت",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Icon(Icons.account_balance_wallet,
                color: Colors.deepPurpleAccent),
          ],
        ),
      ),
    );
  }

  /// 🔘 زر
  Widget _animatedButton(int index, Widget child) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final buttons = [
      const _HomeButtonWrapper(
        icon: Icons.search,
        title: "حجز رحلات",
        screen: TripTypeScreen(),
      ),
      const _HomeButtonWrapper(
        icon: Icons.business,
        title: "شركات النقل",
        screen: CompaniesScreen(),
      ),
      const _HomeButtonWrapper(
        icon: Icons.person,
        title: "المشرف",
        screen: SupervisorLoginScreen(),
      ),
      const _HomeButtonWrapper(
        icon: Icons.confirmation_number,
        title: "تذاكري",
        screen: TicketsScreen(),
      ),
      const _HomeButtonWrapper(
        icon: Icons.account_balance_wallet,
        title: "المحفظة",
        screen: WalletScreen(),
      ),
      const _HomeButtonWrapper(
        icon: Icons.support_agent,
        title: "الدعم",
        screen: SupportScreen(),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A0033),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// 🔝 الهيدر
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "منصة العودة",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _buildNotificationIcon(),
                        GestureDetector(
                          onTap: _handleTap,
                          onLongPress: _handleLongPress,
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.home,
                              size: 22,
                              color: Colors.white24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// 👤 الكرت
              _buildUserCard(),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: buttons.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      return _animatedButton(index, buttons[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeButtonWrapper extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget screen;

  const _HomeButtonWrapper({
    required this.icon,
    required this.title,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white24),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.circle,
                      color: Colors.transparent, size: 0),
                  Icon(icon,
                      color: Colors.deepPurpleAccent,
                      size: 30),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}