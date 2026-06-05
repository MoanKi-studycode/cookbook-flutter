import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/helper/auth_helper.dart';
import 'package:nhom2_flutter_app/page/page_register.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  bool dangXuLy = false;

  static Color mauCamNut = Color(0xFFF2781B);
  static Color mauNenCamNhat = Color(0xFFFFF8F1);

  @override
  void dispose() {
    txtEmail.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Vui lòng nhập email";
    if (!value.contains("@")) return "Email không hợp lệ";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Vui lòng nhập mật khẩu";
    if (value.length < 6) return "Mật khẩu ít nhất 6 ký tự";
    return null;
  }

  Future<void> dangNhap() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => dangXuLy = true);
    try {
      await signInAuth(txtEmail.text, txtPassword.text);
      if (!mounted) return;
    } catch (e) {
      print("[PageLogin] dangNhap ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể đăng nhập. Vui lòng kiểm tra email và mật khẩu.")),
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
        title: Text("Đăng nhập", style: TextStyle(fontWeight: FontWeight.bold)),
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
                SizedBox(height: 20),
                TextFormField(
                  controller: txtEmail,
                  validator: validateEmail,
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
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: txtPassword,
                  validator: validatePassword,
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
                      borderSide: BorderSide(color: mauCamNut, width: 1.5),
                    ),
                  ),
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
                    onPressed: dangXuLy ? null : dangNhap,
                    child: dangXuLy
                        ? SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text("Đăng nhập", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (txtEmail.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Vui lòng nhập email trước")),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PageVerifyOtp(email: txtEmail.text.trim()),
                            ),
                          );
                        },
                        child: Text(
                          "Đã đăng ký? Nhập mã OTP",
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PageRegister()),
                          );
                        },
                        child: Text(
                          "Chưa có tài khoản? Đăng ký ngay",
                          style: TextStyle(color: mauCamNut, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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