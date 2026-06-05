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

  static const Color mauCamNut = Color(0xFFF2781B);
  static const Color mauNenCamNhat = Color(0xFFFFF8F1);

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
          MaterialPageRoute(builder: (context) => PageMain()),
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
        MaterialPageRoute(builder: (context) => PageLogin()),
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
      backgroundColor: mauNenCamNhat,
      appBar: AppBar(
        title: Text("Đăng ký", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(
                  "Vui lòng điền thông tin bên dưới để đăng ký.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: txtHoTen,
                  decoration: InputDecoration(
                    labelText: "Họ và tên",
                    hintText: "Nhập họ và tên của bạn",
                    prefixIcon: Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: mauCamNut, width: 1.5),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? "Nhập họ tên" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: txtEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "email@example.com",
                    prefixIcon: Icon(Icons.mail_outline),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: mauCamNut, width: 1.5),
                    ),
                  ),
                  validator: (v) => (v == null || !v.contains("@")) ? "Email không hợp lệ" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: txtPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    hintText: "••••••••",
                    prefixIcon: Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mauCamNut, width: 1.5),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? "Ít nhất 6 ký tự" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: txtPassword2,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Xác nhận mật khẩu",
                    hintText: "••••••••",
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mauCamNut, width: 1.5),
                    ),
                  ),
                  validator: (v) => v != txtPassword.text ? "Không trùng khớp" : null,
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mauCamNut,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: dangXuLy ? null : dangKy,
                    child: dangXuLy
                        ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text("Đăng ký", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Đã có tài khoản? ",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const PageLogin()),
                          );
                        },
                        child: Text(
                          "Đăng nhập ngay",
                          style: TextStyle(
                            color: mauCamNut,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}