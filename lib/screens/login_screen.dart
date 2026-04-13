import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/user_session.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import 'verify_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {

    if (isLoading) return;

    String phoneInput = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (phoneInput.isEmpty || password.isEmpty) {
      showMsg("أدخل كل البيانات");
      return;
    }

    // ✅ تحقق من الرقم (بدون +)
    if (!RegExp(r'^[0-9]{9,15}$').hasMatch(phoneInput)) {
      showMsg("أدخل رقم هاتف صحيح");
      return;
    }

    if (password.length < 6) {
      showMsg("كلمة المرور قصيرة");
      return;
    }

    setState(() => isLoading = true);

    try {

      // 🔥 بدون أي تعديل للرقم هنا
      final response = await ApiService.login(phoneInput, password);

      if (!mounted) return;

      if (response["success"] != true) {
        showMsg(response["message"] ?? "فشل تسجيل الدخول");
        return;
      }

      Map<String, dynamic> user;

      if (response["user"] is Map) {
        user = Map<String, dynamic>.from(response["user"]);
      } else if (response["data"] is Map) {
        user = Map<String, dynamic>.from(response["data"]);
      } else {
        showMsg("بيانات المستخدم غير صحيحة");
        return;
      }

      /// 🚫 الحظر
      if (user["isBlocked"] == true || user["is_blocked"] == true) {
        showMsg("تم حظر حسابك ❌");
        return;
      }

      /// ✅ التفعيل
      if (user["is_verified"] != true) {

        String email = (user["email"] ?? "").toString();

        if (email.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyScreen(
                email: email,
                username: (user["name"] ?? phoneInput).toString(),
              ),
            ),
          );
        } else {
          showMsg("يجب تفعيل الحساب أولاً");
        }

        return;
      }

      String userId = (
        user["id"] ??
        user["user_id"] ??
        user["_id"] ??
        ""
      ).toString();

      if (userId.isEmpty || userId == "null") {
        showMsg("فشل تسجيل الدخول");
        return;
      }

      String token = (
        response["token"] ??
        response["access_token"] ??
        ""
      ).toString();

      if (token.isEmpty) {
        showMsg("خطأ في التوكن");
        return;
      }

      String walletId = (
        user["wallet_id"] ??
        user["walletId"] ??
        "default_wallet"
      ).toString();

      double balance = 0;
      final rawBalance = user["balance"];

      if (rawBalance is int) {
        balance = rawBalance.toDouble();
      } else if (rawBalance is double) {
        balance = rawBalance;
      } else if (rawBalance is String) {
        balance = double.tryParse(rawBalance) ?? 0;
      }

      await UserSession.setUser(
        uid: userId,
        name: (user["name"] ?? phoneInput).toString(),
        userEmail: (user["email"] ?? "").toString(),
        wallet: walletId,
        userBalance: balance,
        userToken: token,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );

    } catch (e) {

      if (!mounted) return;
      showMsg("فشل الاتصال بالسيرفر ❌");

    } finally {

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل الدخول")),

      body: AbsorbPointer(
        absorbing: isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const SizedBox(height: 40),

              TextField(
                controller: usernameController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "رقم الهاتف",
                  prefixIcon: Icon(Icons.phone),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "كلمة المرور",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("تسجيل الدخول"),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text("هل نسيت كلمة المرور؟"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  );
                },
                child: const Text("إنشاء حساب"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}