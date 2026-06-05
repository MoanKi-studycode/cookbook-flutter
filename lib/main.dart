import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/page/page_home.dart';
import 'package:nhom2_flutter_app/page/page_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = "https://tovuzqtkmwsoeaisbozr.supabase.co";
const String supabaseAnonKey = "sb_publishable_OW8ZvoGSfTsfcDURaz_DMA_QNg0tDcA";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(CookBookApp());
}

class CookBookApp extends StatelessWidget {
  const CookBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookBook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      ),
      home: PageAuthGate(),
    );
  }
}

class PageAuthGate extends StatelessWidget {
  const PageAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text("CookBook"),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Đang tải dữ liệu..."),
                ],
              ),
            ),
          );
        }
        final session = snapshot.data?.session;
        if (session != null) {
          return PageHome();
        }
        return PageLogin();
      },
    );
  }
}
