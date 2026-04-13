import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {

  List users = [];
  List filteredUsers = [];

  bool loading = true;

  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController walletController = TextEditingController();

  bool searchById = false;
  bool searchByName = false;
  bool searchByEmail = false;
  bool searchByWallet = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final data = await ApiService.post(
        "/admin/search-users",
        {},
      );

      if (data["success"] == true) {
        setState(() {
          users = data["data"];
          filteredUsers = users;
          loading = false;
        });
      }
    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
    }
  }

  Future<void> search() async {
    try {

      Map<String, dynamic> body = {};

      if (searchById && idController.text.isNotEmpty) {
        body["id"] = idController.text.trim();
      }

      if (searchByName && nameController.text.isNotEmpty) {
        body["name"] = nameController.text.trim();
      }

      if (searchByEmail && emailController.text.isNotEmpty) {
        body["email"] = emailController.text.trim();
      }

      if (searchByWallet && walletController.text.isNotEmpty) {
        body["wallet"] = walletController.text.trim();
      }

      if (body.isEmpty) {
        showMsg("اختر طريقة بحث واحدة على الأقل ⚠️");
        return;
      }

      final data = await ApiService.post(
        "/admin/search-users",
        body,
      );

      if (data["success"] == true) {
        setState(() {
          filteredUsers = data["data"];
        });
      } else {
        showMsg("لا توجد نتائج ❌");
      }

    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
    }
  }

  Future<void> toggleBlock(String userId, bool currentState) async {
    try {
      final data = await ApiService.post(
        "/admin/users/block",
        {
          "userId": userId,
          "block": !currentState,
        },
      );

      if (data["success"] == true) {
        showMsg(!currentState ? "تم الحظر 🚫" : "تم فك الحظر ✅");
        search();
      }
    } catch (e) {
      showMsg("خطأ في الاتصال ❌");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(title),
      ],
    );
  }

  Widget buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: hint,
        ),
      ),
    );
  }

  Widget buildUserCard(Map user) {

    bool isBlocked = user["isblocked"] ?? false;

    return Card(
      child: ListTile(
        title: Text(user["name"] ?? ""),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID: ${user["id"]}"),
            Text("Email: ${user["email"]}"),
            Text("Wallet: ${user["wallet_id"]}"),
            Text(
              isBlocked ? "🚫 محظور" : "✅ نشط",
              style: TextStyle(
                color: isBlocked ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isBlocked ? Colors.green : Colors.red,
          ),
          onPressed: () =>
              toggleBlock(user["id"].toString(), isBlocked),
          child: Text(isBlocked ? "فك الحظر" : "حظر"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة المستخدمين")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [

                  Wrap(
                    children: [
                      buildCheckbox("ID", searchById,
                          (v) => setState(() => searchById = v!)),
                      buildCheckbox("الاسم", searchByName,
                          (v) => setState(() => searchByName = v!)),
                      buildCheckbox("الإيميل", searchByEmail,
                          (v) => setState(() => searchByEmail = v!)),
                      buildCheckbox("المحفظة", searchByWallet,
                          (v) => setState(() => searchByWallet = v!)),
                    ],
                  ),

                  if (searchById)
                    buildTextField("ID", idController),
                  if (searchByName)
                    buildTextField("الاسم", nameController),
                  if (searchByEmail)
                    buildTextField("الإيميل", emailController),
                  if (searchByWallet)
                    buildTextField("رقم المحفظة", walletController),

                  ElevatedButton(
                    onPressed: search,
                    child: const Text("بحث"),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (c, i) =>
                          buildUserCard(filteredUsers[i]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}