import 'dart:ui';
import 'package:flutter/material.dart';

// الشاشات
import 'supervisor_register_screen.dart';
import 'supervisor_login_screen.dart';
import 'supervisor_dashboard_screen.dart';

import '../utils/user_session.dart'; // 🔥 إضافة

class SupervisorScreen extends StatelessWidget {
  const SupervisorScreen({super.key});

  /// 🔥 تنقل آمن
  void navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// 🔥 فحص تسجيل مسبق (Auto Login)
  void checkLogin(BuildContext context) {
    final user = UserSession.user;

    if (user != null && user["type"] == "supervisor") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SupervisorDashboardScreen(
            companyName: user["companyName"] ?? "",
            supervisorName: user["name"] ?? "",
            officeLocation: user["office"] ?? "",
            companyCode: user["companyCode"] ?? "",
            tripCode: user["tripCode"] ?? "",
            category: user["category"] ?? "company",
            supervisorPhone: user["phone"] ?? "",
          ),
        ),
      );
    }
  }

  /// 💎 زر Glass
  Widget buildButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () => navigate(context, screen),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withOpacity(0.3),
                  Colors.black.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),

                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(icon, color: Colors.white, size: 24),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 18),

                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    /// 🔥 أهم سطر (تشغيل Auto Login)
    Future.microtask(() => checkLogin(context));

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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              const Text(
                "لوحة المشرف",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "اختر العملية المناسبة",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              buildButton(
                context: context,
                icon: Icons.app_registration,
                title: "تسجيل مشرف جديد",
                screen: const SupervisorRegisterScreen(),
              ),

              const SizedBox(height: 20),

              buildButton(
                context: context,
                icon: Icons.login,
                title: "دخول مشرف",
                screen: const SupervisorLoginScreen(),
              ),

              const SizedBox(height: 40),

              const Center(
                child: Text(
                  "إذا لم يكن لديك حساب، قم بالتسجيل أولاً",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
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