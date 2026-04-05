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

  bool isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(username);
  }

  Future<void> login() async {

    if (isLoading) return;

    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showMsg("أدخل كل البيانات");
      return;
    }

    if (!isValidUsername(username)) {
      showMsg("اسم المستخدم يجب أن يكون حروف إنجليزية وأرقام فقط");
      return;
    }

    if (password.length < 6) {
      showMsg("كلمة المرور قصيرة");
      return;
    }

    setState(() => isLoading = true);

    try {

      final response = await ApiService.login(username, password);

      if (!mounted) return;

      if (response["success"] != true) {
        showMsg(response["message"] ?? "فشل تسجيل الدخول");
        setState(() => isLoading = false);
        return;
      }

      Map<String, dynamic> user;

      if (response["user"] is Map) {
        user = Map<String, dynamic>.from(response["user"]);
      } else if (response["data"] is Map) {
        user = Map<String, dynamic>.from(response["data"]);
      } else {
        showMsg("بيانات المستخدم غير صحيحة");
        setState(() => isLoading = false);
        return;
      }

      /// 🚫 التحقق من الحظر
      if (user["isBlocked"] == true || user["is_blocked"] == true) {
        showMsg("تم حظر حسابك ❌");
        setState(() => isLoading = false);
        return;
      }

      /// ✅ التحقق من التفعيل
      if (user["is_verified"] != true) {

        String email = (user["email"] ?? "").toString();

        if (email.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyScreen(
                email: email,
                username: (user["name"] ?? username).toString(),
              ),
            ),
          );
        } else {
          showMsg("يجب تفعيل الحساب أولاً");
        }

        setState(() => isLoading = false);
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
        setState(() => isLoading = false);
        return;
      }

      String token = (
        response["token"] ??
        response["access_token"] ??
        ""
      ).toString();

      if (token.isEmpty) {
        showMsg("خطأ في التوكن");
        setState(() => isLoading = false);
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
        name: (user["name"] ?? username).toString(),
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
                decoration: const InputDecoration(
                  labelText: "اسم المستخدم",
                  prefixIcon: Icon(Icons.person),
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
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
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