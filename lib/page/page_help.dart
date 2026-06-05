import 'package:flutter/material.dart';

class PageHelp extends StatelessWidget {
  const PageHelp({super.key});

  static Color mauChinh = Color(0xFFE85D04);
  static Color mauNen = Color(0xFFFFFBF7);
  static String emailLienHe = "cookbook_ntu@ntu.edu.vn";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mauNen,
      appBar: AppBar(
        title: Text("Hỗ trợ & Trợ giúp", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: mauNen,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), mauChinh],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CookBook",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Ứng dụng tra cứu và lưu công thức nấu ăn dành cho sinh viên NTU.",
                      style: TextStyle(color: Colors.white, height: 1.4),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              _section("Hướng dẫn nhanh", [
                "Tìm món ăn qua tab Tìm hoặc ô tìm kiếm ở trang chủ.",
                "Nhấn biểu tượng trái tim để lưu món vào Yêu thích.",
                "Vào chi tiết món để xem nguyên liệu, cách làm và độ khó.",
                "Tab Cá nhân để quản lý tài khoản và đăng xuất.",
              ]),
              SizedBox(height: 20),
              _section("Câu hỏi thường gặp", [
                "Quên mật khẩu: dùng chức năng quên mật khẩu trên màn hình đăng nhập Supabase hoặc liên hệ email bên dưới.",
                "Không nhận được mã OTP: kiểm tra hộp thư spam hoặc gửi lại mã sau 60 giây.",
                "Không thêm được yêu thích: cần đăng nhập trước khi lưu món.",
              ]),
              SizedBox(height: 20),
              Text(
                "Liên hệ hỗ trợ",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFFFE0C2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, color: mauChinh),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          SizedBox(height: 4),
                          SelectableText(
                            emailLienHe,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: mauChinh,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Gửi email mô tả lỗi hoặc góp ý, nhóm phát triển sẽ phản hồi trong thời gian sớm nhất.",
                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        SizedBox(height: 10),
        ...items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• ", style: TextStyle(color: mauChinh, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(item, style: TextStyle(height: 1.35, color: Colors.black87)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
