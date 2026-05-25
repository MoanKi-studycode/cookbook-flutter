import 'package:nhom2_flutter_app/helper/supabase_helper.dart';
import 'package:nhom2_flutter_app/model/user.dart' as model;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInAuth(String email, String password) async {
  try {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    await dongBoUserSauAuth();
    print("[Auth] signIn ok");
  } catch (e) {
    print("[Auth] signIn ERROR: $e");
    rethrow;
  }
}

Future<AuthResponse> signUpAuth(
  String email,
  String password, {
  String? hoTen,
}) async {
  try {
    final String ten = hoTen?.trim() ?? "";
    final Map<String, dynamic>? metadata = ten.isNotEmpty
        ? {
            'hoTen': ten,
            'full_name': ten,
          }
        : null;

    final res = await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: metadata,
    );

    if (res.session != null && res.user != null) {
      await dongBoUserSauAuth(hoTen: ten);
    }

    print("[Auth] signUp ok");
    return res;
  } catch (e) {
    print("[Auth] signUp ERROR: $e");
    rethrow;
  }
}

Future<AuthResponse> verifyEmailOtpAuth(String email, String token) async {
  try {
    final res = await supabase.auth.verifyOTP(
      type: OtpType.signup,
      email: email.trim(),
      token: token.trim(),
    );
    await dongBoUserSauAuth();
    print("[Auth] verifyOTP ok");
    return res;
  } catch (e) {
    print("[Auth] verifyOTP ERROR: $e");
    rethrow;
  }
}

Future<void> resendSignUpOtpAuth(String email) async {
  try {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
    );
    print("[Auth] resend OTP ok");
  } catch (e) {
    print("[Auth] resend OTP ERROR: $e");
    rethrow;
  }
}

Future<void> signOutAuth() async {
  try {
    await supabase.auth.signOut();
    print("[Auth] signOut ok");
  } catch (e) {
    print("[Auth] signOut ERROR: $e");
    rethrow;
  }
}

Future<void> dongBoUserSauAuth({String? hoTen}) async {
  final authUser = supabase.auth.currentUser;
  if (authUser == null) return;

  final String? ten = (hoTen != null && hoTen.trim().isNotEmpty)
      ? hoTen.trim()
      : model.layHoTenTuAuthMetadata(authUser.userMetadata);

  final profile = model.User(
    id: authUser.id,
    email: authUser.email ?? "",
    hoTen: ten,
  );

  await model.UserSnapshot.luuProfile(profile);

  if (ten != null && ten.isNotEmpty) {
    try {
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'hoTen': ten,
            'full_name': ten,
          },
        ),
      );
    } catch (e) {
      print("[Auth] updateUser metadata ERROR: $e");
    }
  }
}

String? getCurrentUserId() {
  return supabase.auth.currentUser?.id;
}

bool canDangNhapNgay(AuthResponse res) {
  return res.session != null && res.user != null;
}

bool canXacThucEmail(AuthResponse res) {
  return res.user != null && res.session == null;
}
