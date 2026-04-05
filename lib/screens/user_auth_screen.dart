import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/user_session.dart';
import 'home_screen.dart';

class UserAuthScreen extends StatefulWidget {
  const UserAuthScreen({super.key});

  @override
  State<UserAuthScreen> createState() => _UserAuthScreenState();
}

class _UserAuthScreenState extends State<UserAuthScreen> {
  bool isLogin = true;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;

  final List<Map<String, dynamic>> users = [];

  String generateId() {
    final random = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        random.nextInt(999999).toString();
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> handleLogin() async {
    if (isLoading) return;

    String username = usernameController.text.trim().toLowerCase();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showMsg("أدخل كل البيانات");
      return;
    }

    setState(() => isLoading = true);

    try {
      Map<String, dynamic>? user;

      for (var u in users) {
        if (u["username_lower"] == username) {
          user = u;
          break;
        }
      }

      if (user == null) {
        showMsg("المستخدم غير موجود");
      } else if (user["password"] != password) {
        showMsg("كلمة المرور غير صحيحة");
      } else {
        UserSession.userId = user["id"];
        UserSession.username = user["username"];
        UserSession.walletId = user["wallet_id"];

        showMsg("تم تسجيل الدخول ✅");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      showMsg("حدث خطأ");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> handleRegister() async {
    if (isLoading) return;

    String name = usernameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      showMsg("املأ كل الحقول");
      return;
    }

    if (name.contains(" ")) {
      showMsg("اسم المستخدم بدون مسافات");
      return;
    }

    if (!email.contains("@")) {
      showMsg("بريد غير صالح");
      return;
    }

    if (phone.length < 8) {
      showMsg("رقم الهاتف غير صحيح");
      return;
    }

    if (password.length < 6) {
      showMsg("كلمة المرور ضعيفة");
      return;
    }

    if (password != confirmPassword) {
      showMsg("كلمات المرور غير متطابقة");
      return;
    }

    setState(() => isLoading = true);

    try {
      bool exists = users.any(
        (u) =>
            u["username_lower"] == name.toLowerCase() ||
            u["email"] == email,
      );

      if (exists) {
        showMsg("المستخدم موجود مسبقاً");
      } else {
        String userId = generateId();
        String walletId = generateId();

        users.add({
          "id": userId,
          "username": name,
          "username_lower": name.toLowerCase(),
          "email": email,
          "phone": phone,
          "password": password,
          "wallet_id": walletId,
          "balance": 0,
          "created_at": DateTime.now().toString(),
        });

        showMsg("تم إنشاء الحساب ✅");

        setState(() => isLogin = true);
      }
    } catch (e) {
      showMsg("خطأ غير متوقع");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? "تسجيل الدخول" : "إنشاء حساب"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "اسم المستخدم"),
              ),

              const SizedBox(height: 15),

              if (!isLogin)
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "البريد الإلكتروني"),
                ),

              if (!isLogin) const SizedBox(height: 15),

              if (!isLogin)
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "رقم الهاتف"),
                ),

              if (!isLogin) const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "كلمة المرور"),
              ),

              if (!isLogin) const SizedBox(height: 15),

              if (!isLogin)
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "تأكيد كلمة المرور"),
                ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : isLogin
                          ? handleLogin
                          : handleRegister,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isLogin ? "تسجيل الدخول" : "إنشاء حساب"),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  setState(() => isLogin = !isLogin);
                },
                child: Text(
                  isLogin
                      ? "إنشاء حساب جديد؟"
                      : "لديك حساب؟ تسجيل الدخول",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}