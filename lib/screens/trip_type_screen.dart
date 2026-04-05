import 'dart:ui';
import 'package:flutter/material.dart';
import 'trip_sub_type_screen.dart';

class TripTypeScreen extends StatefulWidget {
  const TripTypeScreen({Key? key}) : super(key: key);

  @override
  State<TripTypeScreen> createState() => _TripTypeScreenState();
}

class _TripTypeScreenState extends State<TripTypeScreen> {
  /// 💎 ألوان ثابتة
  static const Color gradientStart = Color(0xFF0D0D0D);
  static const Color gradientEnd = Color(0xFF1A0033);
  static const Color buttonColor1 = Colors.deepPurple;
  static const Color buttonColor2 = Colors.blueAccent;

  bool isNavigating = false;

  void navigate(BuildContext context, String type) {
    if (isNavigating) return;
    isNavigating = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripSubTypeScreen(mainType: type),
      ),
    ).then((_) {
      isNavigating = false;
    });
  }

  Widget _buildTripButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String type,
  ) {
    return GestureDetector(
      onTap: () => navigate(context, type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              buttonColor1.withOpacity(0.6),
              buttonColor2.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: buttonColor1.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  /// 🔵 أيقونة
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [buttonColor1, buttonColor2],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),

                  const SizedBox(width: 20),

                  /// 📝 النصوص
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ➡️ سهم
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                /// 🚌 أيقونة
                const Icon(
                  Icons.directions_bus,
                  size: 90,
                  color: Colors.white,
                ),

                const SizedBox(height: 25),

                /// 📝 عنوان
                const Text(
                  "اختر نوع الرحلة",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                /// 🔘 الأزرار
                _buildTripButton(
                  context,
                  Icons.person,
                  "رحلات خاصة",
                  "شركات نقل أو أصحاب عربات",
                  "private",
                ),

                _buildTripButton(
                  context,
                  Icons.group,
                  "رحلات طوعية",
                  "شركات نقل + قوات SUD (مجاني)",
                  "voluntary",
                ),

                _buildTripButton(
                  context,
                  Icons.local_shipping,
                  "الشحن",
                  "إرسال واستلام الطرود",
                  "shipping",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}