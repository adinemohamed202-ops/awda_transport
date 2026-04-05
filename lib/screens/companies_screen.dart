import 'dart:ui';
import 'package:flutter/material.dart';

import 'company_register_screen.dart';
import 'vehicle_register_screen.dart';
import 'company_code_screen.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  Widget buildButton(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
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
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 لاحقاً تربطها بـ API
  Future<Map<String, String>> fetchCodes() async {
    return {
      "companyCode": "COMP-001",
      "tripsCode": "TRIP-001",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("شركات النقل"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Map<String, String>>(
        future: fetchCodes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final codes = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                /// 🏢 تسجيل شركة
                buildButton(
                  context,
                  Icons.business,
                  "تسجيل شركة",
                  const CompanyRegisterScreen(),
                ),

                /// 🚗 تسجيل عربة
                buildButton(
                  context,
                  Icons.directions_car,
                  "تسجيل عربة",
                  const VehicleRegisterScreen(),
                ),

                /// 👁️ عرض رحلات
                buildButton(
                  context,
                  Icons.remove_red_eye,
                  "عرض رحلات",
                  CompanyCodeScreen(
                    companyCode: codes["companyCode"]!,
                    tripsCode: codes["tripsCode"]!,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}