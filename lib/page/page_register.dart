import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nhom2_flutter_app/helper/auth_helper.dart';
import 'package:nhom2_flutter_app/page/page_auth_gate.dart';
import 'package:nhom2_flutter_app/page/page_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  static Color mauCamNut = Color(0xFFF2781B);
  static Color mauNenCamNhat = Color(0xFFFFF8F1);

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
      print("[PageRegister] dangKy ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể đăng ký. Vui lòng thử lại sau.")),
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
                      borderSide: BorderSide(color: mauCamNut, width: 1.5),
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
                        ? SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text("Đăng ký", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            MaterialPageRoute(builder: (context) => PageLogin()),
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

class PageVerifyOtp extends StatefulWidget {
  final String email;

  const PageVerifyOtp({super.key, required this.email});

  @override
  State<PageVerifyOtp> createState() => _PageVerifyOtpState();
}

class _PageVerifyOtpState extends State<PageVerifyOtp> {
  static Color mauCamNut = Color(0xFFF2781B);
  static Color mauNenCamNhat = Color(0xFFFFF8F1);

  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  bool dangXuLy = false;
  bool dangGuiLai = false;
  bool daThanhCong = false;
  int demNguoc = 60;
  String loiOtp = "";
  String thongBaoThanhCong = "";

  @override
  void initState() {
    super.initState();
    batDemNguoc();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void batDemNguoc() {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (!mounted) return false;
      if (demNguoc > 0) {
        setState(() => demNguoc--);
        return true;
      }
      return false;
    });
  }

  String layMaOtp() {
    return otpControllers.map((c) => c.text.trim()).join();
  }

  void xoaMaOtp() {
    for (final c in otpControllers) {
      c.clear();
    }
    focusNodes[0].requestFocus();
  }

  void khiNhapOtp(int index, String value) {
    if (dangXuLy) return;

    if (loiOtp.isNotEmpty) {
      setState(() => loiOtp = "");
    }

    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6; i++) {
        otpControllers[i].text = i < digits.length ? digits[i] : "";
      }
      if (digits.length >= 6) {
        focusNodes[5].unfocus();
        xacThucMa();
      } else if (digits.isNotEmpty) {
        focusNodes[digits.length.clamp(0, 5)].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }

    if (layMaOtp().length == 6) {
      focusNodes[5].unfocus();
      xacThucMa();
    }
  }

  Future<void> xacThucMa() async {
    final ma = layMaOtp();
    if (ma.length != 6 || dangXuLy || daThanhCong) return;

    setState(() {
      dangXuLy = true;
      loiOtp = "";
    });

    try {
      await verifyEmailOtpAuth(widget.email, ma);
      if (!mounted) return;

      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        setState(() {
          dangXuLy = false;
          daThanhCong = true;
          thongBaoThanhCong = "Xác thực thành công! Đang chuyển vào ứng dụng...";
        });
        await Future.delayed(Duration(milliseconds: 900));
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => PageAuthGate()),
          (route) => false,
        );
        return;
      }

      setState(() {
        dangXuLy = false;
        daThanhCong = true;
        thongBaoThanhCong = "Xác thực thành công! Vui lòng đăng nhập.";
      });
      await Future.delayed(Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => PageLogin()),
        (route) => false,
      );
    } catch (e) {
      print("[PageVerifyOtp] xacThucMa ERROR: $e");
      if (!mounted) return;
      setState(() {
        dangXuLy = false;
        loiOtp = "Mã xác thực không đúng. Vui lòng thử lại.";
      });
      xoaMaOtp();
    }
  }

  Future<void> guiLaiMa() async {
    setState(() {
      dangGuiLai = true;
      loiOtp = "";
    });
    try {
      await resendSignUpOtpAuth(widget.email);
      if (!mounted) return;
      xoaMaOtp();
      setState(() => demNguoc = 60);
      batDemNguoc();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã gửi lại mã OTP")),
      );
    } catch (e) {
      print("[PageVerifyOtp] guiLaiMa ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể gửi lại mã. Vui lòng thử lại sau.")),
      );
    } finally {
      if (mounted) setState(() => dangGuiLai = false);
    }
  }

  Widget _buildOtpBox(int index) {
    final coLoi = loiOtp.isNotEmpty;
    return SizedBox(
      width: 46,
      height: 54,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event.logicalKey == LogicalKeyboardKey.backspace &&
              otpControllers[index].text.isEmpty &&
              index > 0) {
            focusNodes[index - 1].requestFocus();
            otpControllers[index - 1].clear();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: otpControllers[index],
          focusNode: focusNodes[index],
          enabled: !dangXuLy && !daThanhCong,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: coLoi ? Colors.redAccent : Color(0xFFFFE0C2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: coLoi ? Colors.redAccent : Color(0xFFFFE0C2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: coLoi ? Colors.redAccent : mauCamNut,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) => khiNhapOtp(index, value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mauNenCamNhat,
      appBar: AppBar(
        title: Text("Xác thực OTP", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              SizedBox(height: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFFFE0C2), width: 2),
                ),
                child: Icon(Icons.mark_email_read_outlined, size: 36, color: mauCamNut),
              ),
              SizedBox(height: 20),
              Text(
                "Nhập mã xác thực",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 10),
              Text(
                "Mã 6 số đã gửi đến",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: mauCamNut,
                ),
              ),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),
              SizedBox(height: 14),
              if (dangXuLy)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: mauCamNut),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Đang xác thực...",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              if (daThanhCong)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 40),
                      SizedBox(height: 8),
                      Text(
                        thongBaoThanhCong,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              if (loiOtp.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    loiOtp,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              SizedBox(height: 28),
              demNguoc > 0
                  ? Text(
                      "Gửi lại mã sau 00:${demNguoc.toString().padLeft(2, '0')}",
                      style: TextStyle(color: Colors.grey.shade600),
                    )
                  : TextButton(
                      onPressed: dangGuiLai || dangXuLy || daThanhCong ? null : guiLaiMa,
                      child: dangGuiLai
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: mauCamNut),
                            )
                          : Text(
                              "Gửi lại mã OTP",
                              style: TextStyle(
                                color: mauCamNut,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
              SizedBox(height: 8),
              TextButton(
                onPressed: dangXuLy || daThanhCong
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => PageRegister()),
                        );
                      },
                child: Text(
                  "Quay lại đăng ký",
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}