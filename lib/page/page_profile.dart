import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/helper/auth_helper.dart';
import 'package:nhom2_flutter_app/helper/dialogs.dart';
import 'package:nhom2_flutter_app/model/user.dart';
import 'package:nhom2_flutter_app/page/page_welcome.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({super.key});

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  String ten = "Người dùng";
  String email = "";

  @override
  void initState() {
    super.initState();
    taiProfile();
  }

  Future<void> taiProfile() async {
    final user = await UserSnapshot.getCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      ten = user?.hoTen ?? "Người dùng";
      email = user?.email ?? "";
    });
  }

  Future<void> dangXuat(BuildContext context) async {
    final String? confirm = await showConfirmDialog(context, "Bạn muốn đăng xuất?");
    if (confirm != "ok") return;
    try {
      await signOutAuth();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PageWelcome()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng xuất: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cá nhân"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(ten, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(email),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.person_outline),
                title: Text("Thông tin tài khoản"),
              ),
              const ListTile(
                leading: Icon(Icons.help_outline),
                title: Text("Trợ giúp"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => dangXuat(context),
                child: const Text("Đăng xuất"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
