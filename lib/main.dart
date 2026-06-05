import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/page/page_splash.dart';
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
      home: PageSplash(),
    );
  }
}
