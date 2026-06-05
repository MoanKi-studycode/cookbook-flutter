import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/page/page_home.dart';
import 'package:nhom2_flutter_app/page/page_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageAuthGate extends StatelessWidget {
  const PageAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return PageHome();
        }
        return PageLogin();
      },
    );
  }
}
