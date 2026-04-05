import 'dart:ui';
import 'package:flutter/material.dart';
import 'trip_list_screen.dart';

class TripSubTypeScreen extends StatefulWidget {
  final String mainType;

  TripSubTypeScreen({
    super.key,
    required this.mainType,
  });

  @override
  State<TripSubTypeScreen> createState() => _TripSubTypeScreenState();
}

class _TripSubTypeScreenState extends State<TripSubTypeScreen> {
  Color gradientStart = Color(0xFF0D0D0D);
  Color gradientEnd = Color(0xFF1A0033);
  Color buttonColor1 = Colors.deepPurple;
  Color buttonColor2 = Colors.blueAccent;

  bool isNavigating = false;

  @override
  void initState() {
    super.initState();

    /// 🔥 الشحن → انتقال مباشر
    if (widget.mainType == "shipping") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TripListScreen(
              tripType: "shipping",
              category: "shipping",
            ),
          ),
        );
      });
    }
  }

  void navigate(String tripType, String category) {
    if (isNavigating) return;
    isNavigating = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripListScreen(
          tripType: tripType,
          category: category,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      isNavigating = false;
    });
  }

  Widget _buildButton(
      String title, String tripType, String category, IconData icon) {
    return GestureDetector(
      onTap: () => navigate(tripType, category),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(vertical: 8),
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
              offset: Offset(0, 5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 75,
              padding: EdgeInsets.symmetric(horizontal: 20),
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
                    padding: EdgeInsets.all(12),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),

                  SizedBox(width: 20),

                  /// 📝 النص
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  /// ➡️ سهم
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 18,
                  )
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
    /// أثناء التحويل (shipping)
    if (widget.mainType == "shipping") {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("اختيار الجهة"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.alt_route, size: 90, color: Colors.white),
                SizedBox(height: 25),

                Text(
                  "اختر نوع الجهة",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 40),

                /// 🔹 رحلات خاصة
                if (widget.mainType == "private") ...[
                  _buildButton(
                      "رحلات شركات", "private", "company", Icons.business),
                  _buildButton("رحلات أصحاب عربات", "private", "car",
                      Icons.directions_car),
                ],

                /// 🔹 رحلات طوعية
                if (widget.mainType == "voluntary") ...[
                  _buildButton(
                      "رحلات شركات", "voluntary", "company", Icons.group),
                  _buildButton("القوات المسلحة (مجاني)", "voluntary",
                      "military", Icons.security),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}