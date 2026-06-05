import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/page/page_auth_gate.dart';

class PageSplash extends StatefulWidget {
  const PageSplash({super.key});

  @override
  State<PageSplash> createState() => _PageSplashState();
}

class _PageSplashState extends State<PageSplash> {
  static Color mauTienTrinh = Color(0xFF1E5FA8);

  @override
  void initState() {
    super.initState();
    chuyenTrang();
  }

  Future<void> chuyenTrang() async {
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PageAuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/splash/splash_screen.png",
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.45),
                    valueColor: AlwaysStoppedAnimation<Color>(mauTienTrinh),
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  "Đang tải hương vị của bạn...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B2B2B),
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.85),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
