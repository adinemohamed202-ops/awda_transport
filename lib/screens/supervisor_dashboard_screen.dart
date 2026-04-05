import 'package:flutter/material.dart';
import 'supervisor_add_trip_screen.dart';
import 'supervisor_bookings_screen.dart';
import 'company_agents_screen.dart';
import 'supervisor_trips_screen.dart';

class SupervisorDashboardScreen extends StatelessWidget {
  final String companyName;
  final String supervisorName;
  final String officeLocation;

  final String companyCode;
  final String tripCode;
  final String category;

  final String supervisorPhone;

  const SupervisorDashboardScreen({
    super.key,
    required this.companyName,
    required this.supervisorName,
    required this.officeLocation,
    required this.companyCode,
    required this.tripCode,
    required this.category,
    required this.supervisorPhone,
  });

  /// 🔥 نوع الحساب
  String getCategoryName() {
    switch (category) {
      case "car":
        return "🚗 صاحب عربة";
      case "shipping":
        return "📦 شحن";
      case "military":
        return "🪖 قوات مسلحة";
      case "company":
      default:
        return "🏢 شركة نقل";
    }
  }

  /// 🔥 زر موحد (تنظيف UI + تقليل تكرار)
  Widget buildButton({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(fontSize: 17),
        ),
        onPressed: onPressed,
      ),
    );
  }

  /// 🔥 انتقال آمن
  void navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم المشرف"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          /// 🔥 كارد المعلومات
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("👤 المشرف: $supervisorName"),
                  Text("📱 الهاتف: $supervisorPhone"),
                  Text("📍 الموقع: $officeLocation"),
                  Text("📂 النوع: ${getCategoryName()}"),
                  const Divider(),
                  Text("🔑 كود الشركة: $companyCode"),
                  Text("🎫 كود الرحلات: $tripCode"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// 🔥 إنشاء رحلة
          buildButton(
            icon: Icons.add_box,
            title: "إنشاء إعلان رحلة",
            onPressed: () {
              navigate(
                context,
                SupervisorAddTripScreen(
                  companyName: companyName,
                  supervisorName: supervisorName,
                  officeLocation: officeLocation,
                  phoneNumber: supervisorPhone,
                  companyCode: companyCode,
                  tripCode: tripCode,
                  category: category,
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          /// 🔥 رحلاتي
          buildButton(
            icon: Icons.directions_bus,
            title: "رحلاتي",
            onPressed: () {
              navigate(
                context,
                SupervisorTripsScreen(
                  companyCode: companyCode,
                  supervisorPhone: supervisorPhone,
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          /// 🔥 طلبات الحجز
          buildButton(
            icon: Icons.chat,
            title: "طلبات الحجز",
            onPressed: () {
              navigate(
                context,
                SupervisorBookingsScreen(
                  companyCode: companyCode,
                  supervisorPhone: supervisorPhone,
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          /// 🔥 إدارة المشرفين
          if (category == "company")
            buildButton(
              icon: Icons.people,
              title: "إدارة المشرفين",
              onPressed: () {
                navigate(
                  context,
                  CompanyAgentsScreen(
                    companyCode: companyCode,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}