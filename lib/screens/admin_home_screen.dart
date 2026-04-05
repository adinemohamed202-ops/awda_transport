import 'dart:ui';
import 'package:flutter/material.dart';

import 'admin_topup_screen.dart';
import 'admin_qr_upload_screen.dart';
import 'admin_users_screen.dart';
import 'admin_login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  /// 🔘 كرت زر احترافي Grid
  Widget buildGridCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(icon, color: gradientColors.last, size: 32),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🚪 تسجيل خروج (جاهز API لو حبيت تضيف logout endpoint لاحقاً)
  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية متدرجة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 👤 عنوان الأدمن + زر خروج
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "لوحة تحكم الأدمن",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () => logout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 🌟 شبكة الأزرار Grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        buildGridCard(
                          context: context,
                          title: "طلبات الإيداع",
                          icon: Icons.account_balance_wallet,
                          gradientColors: [Colors.orange, Colors.deepOrange],
                          screen: const AdminTopUpScreen(),
                        ),
                        buildGridCard(
                          context: context,
                          title: "رفع QR",
                          icon: Icons.qr_code,
                          gradientColors: [Colors.green, Colors.teal],
                          screen: const AdminQrUploadScreen(),
                        ),
                        buildGridCard(
                          context: context,
                          title: "إدارة المستخدمين",
                          icon: Icons.people,
                          gradientColors: [Colors.blue, Colors.indigo],
                          screen: const AdminUsersScreen(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}