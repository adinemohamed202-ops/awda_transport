import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import 'verify_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  String countryCode = "+249";

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// ✅ username: حروف صغيرة + أرقام
  bool isValidUsername(String username) {
    final regex = RegExp(r'^[a-z0-9]{3,20}$');
    return regex.hasMatch(username);
  }

  Future<void> register() async {

    FocusScope.of(context).unfocus();

    String username = usernameController.text.trim();
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    /// ✅ تحقق
    if (username.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      showMsg("املأ كل الحقول");
      return;
    }

    if (!isValidUsername(username)) {
      showMsg("اسم المستخدم (3-20) حروف إنجليزية صغيرة وأرقام فقط");
      return;
    }

    if (!RegExp(r'^\d{9,15}$').hasMatch(phone)) {
      showMsg("رقم الهاتف غير صحيح");
      return;
    }

    /// ❌ منع إدخال 0 في البداية
    if (phone.startsWith("0")) {
      showMsg("لا تكتب 0 في بداية الرقم");
      return;
    }

    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
      showMsg("بريد غير صالح");
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

    /// ✅ تحويل الرقم للصيغة الدولية (نفس اللوقن)
    String fullPhone = countryCode + phone;

    setState(() => isLoading = true);

    try {

      final response = await ApiService.register(
        username: username,
        email: email,
        password: password,
        phone: fullPhone,
      );

      if (!mounted) return;

      if (response["success"] == true) {

        showMsg("تم إرسال كود التحقق 📩");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyScreen(
              email: email,
              username: username,
            ),
          ),
        );

      } else {
        showMsg(response["message"] ?? "فشل التسجيل");
      }

    } catch (e) {
      if (!mounted) return;
      showMsg("خطأ في الاتصال بالسيرفر");
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
      appBar: AppBar(title: const Text("إنشاء حساب")),

      body: AbsorbPointer(
        absorbing: isLoading,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 30),

                TextField(
                  controller: usernameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: "اسم المستخدم",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [

                    DropdownButton<String>(
                      value: countryCode,
                      items: const [
                        DropdownMenuItem(value: "+249", child: Text("🇸🇩 +249")),
                        DropdownMenuItem(value: "+20", child: Text("🇪🇬 +20")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          countryCode = value!;
                        });
                      },
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: "رقم الهاتف بدون 0",
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "البريد الإلكتروني",
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 15),

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

                const SizedBox(height: 15),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscurePassword,
                  decoration: const InputDecoration(
                    labelText: "تأكيد كلمة المرور",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("إنشاء حساب"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}