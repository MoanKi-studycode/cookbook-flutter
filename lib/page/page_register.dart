import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/helper/auth_helper.dart';
import 'package:nhom2_flutter_app/page/page_login.dart';
import 'package:nhom2_flutter_app/page/page_main.dart';
import 'package:nhom2_flutter_app/page/page_verify_otp.dart';

class PageRegister extends StatefulWidget {
  const PageRegister({super.key});

  @override
  State<PageRegister> createState() => _PageRegisterState();
}

class _PageRegisterState extends State<PageRegister> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController txtHoTen = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtPassword2 = TextEditingController();
  bool dangXuLy = false;

  @override
  void dispose() {
    txtHoTen.dispose();
    txtEmail.dispose();
    txtPassword.dispose();
    txtPassword2.dispose();
    super.dispose();
  }

  Future<void> dangKy() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => dangXuLy = true);
    try {
      final res = await signUpAuth(
        txtEmail.text,
        txtPassword.text,
        hoTen: txtHoTen.text.trim(),
      );
      if (!mounted) return;

      if (canDangNhapNgay(res)) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PageMain()),
          (route) => false,
        );
        return;
      }

      if (canXacThucEmail(res)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PageVerifyOtp(email: txtEmail.text.trim()),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PageLogin()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thất bại: $e")),
      );
    } finally {
      if (mounted) setState(() => dangXuLy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng ký"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: txtHoTen,
                  decoration: const InputDecoration(labelText: "Họ và tên"),
                  validator: (v) => (v == null || v.isEmpty) ? "Nhập họ tên" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (v) => (v == null || !v.contains("@")) ? "Email không hợp lệ" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtPassword,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Mật khẩu"),
                  validator: (v) => (v == null || v.length < 6) ? "Ít nhất 6 ký tự" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtPassword2,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Xác nhận mật khẩu"),
                  validator: (v) => v != txtPassword.text ? "Không trùng khớp" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: dangXuLy ? null : dangKy,
                  child: dangXuLy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Đăng ký"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PageLogin()),
                    );
                  },
                  child: const Text("Đã có tài khoản? Đăng nhập"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
