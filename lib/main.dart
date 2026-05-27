import 'package:flutter/material.dart';
import "package:nhom2_flutter_app/page/page_main.dart";
import 'package:nhom2_flutter_app/page/page_splash.dart';
import 'package:nhom2_flutter_app/page/page_welcome.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: thay URL va anon key Supabase cua nhom
const String supabaseUrl = "https://tovuzqtkmwsoeaisbozr.supabase.co";
const String supabaseAnonKey = "sb_publishable_OW8ZvoGSfTsfcDURaz_DMA_QNg0tDcA";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const CookBookApp());
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
      home: const PageAppStart(),
    );
  }
}

class PageAppStart extends StatefulWidget {
  const PageAppStart({super.key});

  @override
  State<PageAppStart> createState() => _PageAppStartState();
}

class _PageAppStartState extends State<PageAppStart> {
  bool hetSplash = false;

  @override
  Widget build(BuildContext context) {
    if (!hetSplash) {
      return PageSplash(
        onHoanThanh: () => setState(() => hetSplash = true),
      );
    }
    return const PageAuthGate();
  }
}

class PageAuthGate extends StatefulWidget {
  const PageAuthGate({super.key});

  @override
  State<PageAuthGate> createState() => _PageAuthGateState();
}

class _PageAuthGateState extends State<PageAuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading..."),
                ],
              ),
            ),
          );
        }
        final session = snapshot.data?.session;
        if (session != null) {
          return const PageMain();
        }
        return const PageWelcome();
      },
    );
  }
}
