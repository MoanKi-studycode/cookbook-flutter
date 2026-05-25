import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nhom2_flutter_app/helper/auth_helper.dart';
import 'package:nhom2_flutter_app/page/page_main.dart';
import 'package:nhom2_flutter_app/page/page_register.dart';

class PageVerifyOtp extends StatefulWidget {
  final String email;

  const PageVerifyOtp({super.key, required this.email});

  @override
  State<PageVerifyOtp> createState() => _PageVerifyOtpState();
}

class _PageVerifyOtpState extends State<PageVerifyOtp> {
  final TextEditingController txtMa = TextEditingController();
  bool dangXuLy = false;
  bool dangGuiLai = false;
  int demNguoc = 60;

  @override
  void initState() {
    super.initState();
    batDemNguoc();
  }

  @override
  void dispose() {
    txtMa.dispose();
    super.dispose();
  }

  void batDemNguoc() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (demNguoc > 0) {
        setState(() => demNguoc--);
        return true;
      }
      return false;
    });
  }

  Future<void> xacThucMa() async {
    final ma = txtMa.text.trim();
    if (ma.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ 6 chữ số")),
      );
      return;
    }
    setState(() => dangXuLy = true);
    try {
      final res = await verifyEmailOtpAuth(widget.email, ma);
      if (!mounted) return;
      if (res.session != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PageMain()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mã OTP không đúng: $e")),
      );
    } finally {
      if (mounted) setState(() => dangXuLy = false);
    }
  }

  Future<void> guiLaiMa() async {
    setState(() => dangGuiLai = true);
    try {
      await resendSignUpOtpAuth(widget.email);
      if (!mounted) return;
      txtMa.clear();
      setState(() => demNguoc = 60);
      batDemNguoc();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã gửi lại mã OTP")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gửi lại thất bại: $e")),
      );
    } finally {
      if (mounted) setState(() => dangGuiLai = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác thực OTP"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mã gửi đến: ${widget.email}"),
              const SizedBox(height: 15),
              TextField(
                controller: txtMa,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Mã OTP (6 số)",
                  counterText: "",
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: dangXuLy ? null : xacThucMa,
                child: dangXuLy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Xác nhận"),
              ),
              const SizedBox(height: 10),
              demNguoc > 0
                  ? Text("Gửi lại sau 00:${demNguoc.toString().padLeft(2, '0')}")
                  : TextButton(
                      onPressed: dangGuiLai ? null : guiLaiMa,
                      child: const Text("Gửi lại mã OTP"),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const PageRegister()),
                  );
                },
                child: const Text("Quay lại đăng ký"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
