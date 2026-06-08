// NguyenThanhThuc - giao dien tai khoan
// TranAnhTin - cap nhat ten, doi mat khau
import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/helper/auth_helper.dart';

class PageAccount extends StatefulWidget {
  const PageAccount({super.key});

  @override
  State<PageAccount> createState() => _PageAccountState();
}

class _PageAccountState extends State<PageAccount> {
  static Color mauCamNut = Color(0xFFF2781B);
  static Color mauNen = Color(0xFFFFFBF7);

  final TextEditingController txtHoTen = TextEditingController();
  final TextEditingController txtMatKhauMoi = TextEditingController();
  final TextEditingController txtMatKhauXacNhan = TextEditingController();

  String email = "";
  bool dangTai = true;
  bool dangCapNhatTen = false;
  bool dangDoiMatKhau = false;

  @override
  void initState() {
    super.initState();
    taiThongTin();
  }

  @override
  void dispose() {
    txtHoTen.dispose();
    txtMatKhauMoi.dispose();
    txtMatKhauXacNhan.dispose();
    super.dispose();
  }

  Future<void> taiThongTin() async {
    setState(() => dangTai = true);
    final user = await getCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      email = user?.email ?? "";
      txtHoTen.text = user?.hoTen ?? "";
      dangTai = false;
    });
  }

  Future<void> capNhatTen() async {
    final ten = txtHoTen.text.trim();
    if (ten.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập tên hiển thị")),
      );
      return;
    }

    setState(() => dangCapNhatTen = true);
    try {
      await capNhatHoTenAuth(ten);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã cập nhật tên hiển thị")),
      );
    } catch (e) {
      print("[PageAccount] capNhatTen ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể cập nhật tên. Vui lòng thử lại.")),
      );
    } finally {
      if (mounted) setState(() => dangCapNhatTen = false);
    }
  }

  Future<void> doiMatKhau() async {
    final mk = txtMatKhauMoi.text;
    final mk2 = txtMatKhauXacNhan.text;

    if (mk.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mật khẩu mới ít nhất 6 ký tự")),
      );
      return;
    }
    if (mk != mk2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mật khẩu xác nhận không trùng khớp")),
      );
      return;
    }

    setState(() => dangDoiMatKhau = true);
    try {
      await doiMatKhauAuth(mk);
      if (!mounted) return;
      txtMatKhauMoi.clear();
      txtMatKhauXacNhan.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã đổi mật khẩu thành công")),
      );
    } catch (e) {
      print("[PageAccount] doiMatKhau ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể đổi mật khẩu. Vui lòng thử lại.")),
      );
    } finally {
      if (mounted) setState(() => dangDoiMatKhau = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mauNen,
      appBar: AppBar(
        title: Text("Tài khoản", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: mauNen,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: dangTai
          ? Center(child: CircularProgressIndicator(color: mauCamNut))
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Thông tin tài khoản"),
                    SizedBox(height: 12),
                    _infoCard(
                      icon: Icons.mail_outline,
                      label: "Email",
                      value: email.isNotEmpty ? email : "Chưa có email",
                    ),
                    SizedBox(height: 24),
                    _sectionTitle("Cập nhật tên hiển thị"),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: txtHoTen,
                      decoration: InputDecoration(
                        labelText: "Tên hiển thị (Display name)",
                        hintText: "Nhập tên của bạn",
                        prefixIcon: Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: mauCamNut, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mauCamNut,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: dangCapNhatTen ? null : capNhatTen,
                        child: dangCapNhatTen
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text("Lưu tên hiển thị"),
                      ),
                    ),
                    SizedBox(height: 28),
                    _sectionTitle("Đổi mật khẩu"),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: txtMatKhauMoi,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Mật khẩu mới",
                        hintText: "••••••••",
                        prefixIcon: Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: txtMatKhauXacNhan,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Xác nhận mật khẩu mới",
                        hintText: "••••••••",
                        prefixIcon: Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: mauCamNut,
                          side: BorderSide(color: mauCamNut),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: dangDoiMatKhau ? null : doiMatKhau,
                        child: dangDoiMatKhau
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: mauCamNut),
                              )
                            : Text("Đổi mật khẩu"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black87),
    );
  }

  Widget _infoCard({required IconData icon, required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFFFE0C2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: mauCamNut),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                SizedBox(height: 4),
                Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
