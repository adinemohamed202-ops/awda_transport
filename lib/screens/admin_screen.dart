import 'package:flutter/material.dart';

import 'admin_home_screen.dart';
import 'admin_login_screen.dart';
import 'admin_deposits_screen.dart'; // 🔥 جديد

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  /// 🔘 زر احترافي للأدمن
  Widget buildAdminButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔐 فتح شاشة تسجيل دخول الأدمن
  void openAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
      ),
    );
  }

  /// 🔥 فتح شاشة الإيداعات مباشرة
  void openDeposits(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDepositsScreen(),
      ),
    );
  }

  /// 🚪 تسجيل خروج
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("لوحة التحكم"),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A1B9A),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_open),
            onPressed: () => openAdmin(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            /// 🔥 أهم زر (تم التعديل)
            buildAdminButton(
              context: context,
              title: "طلبات شحن الكريدت",
              icon: Icons.account_balance_wallet,
              color: Colors.orange,
              onTap: () => openDeposits(context), // 🔥 هنا التعديل
            ),

            buildAdminButton(
              context: context,
              title: "المحافظ",
              icon: Icons.wallet,
              color: Colors.blue,
              onTap: () => openAdmin(context),
            ),

            buildAdminButton(
              context: context,
              title: "الرحلات",
              icon: Icons.directions_bus,
              color: Colors.green,
              onTap: () => openAdmin(context),
            ),

            buildAdminButton(
              context: context,
              title: "الشركات",
              icon: Icons.business,
              color: Colors.purple,
              onTap: () => openAdmin(context),
            ),

            buildAdminButton(
              context: context,
              title: "المستخدمين",
              icon: Icons.people,
              color: Colors.teal,
              onTap: () => openAdmin(context),
            ),

            buildAdminButton(
              context: context,
              title: "العمليات المالية",
              icon: Icons.attach_money,
              color: Colors.redAccent,
              onTap: () => openAdmin(context),
            ),
          ],
        ),
      ),
    );
  }
}