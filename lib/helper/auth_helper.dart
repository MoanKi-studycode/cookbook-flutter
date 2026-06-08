// TranAnhTin - xac thuc nguoi dung (Supabase Auth): dang ky, dang nhap, OTP, cap nhat ho ten, doi mat khau, profile
import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/helper/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInAuth(String email, String password) async {
  try {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
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
            'display_name': ten,
            'full_name': ten,
            'hoTen': ten,
          }
        : null;

    final res = await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: metadata,
    );

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

Future<void> capNhatHoTenAuth(String hoTen) async {
  final authUser = supabase.auth.currentUser;
  if (authUser == null) {
    throw Exception("not logged in");
  }

  final ten = hoTen.trim();
  if (ten.isEmpty) {
    throw Exception("empty name");
  }

  try {
    await supabase.auth.updateUser(
      UserAttributes(
        data: {
          'display_name': ten,
          'full_name': ten,
          'hoTen': ten,
        },
      ),
    );
    print("[Auth] capNhatHoTen ok");
  } catch (e) {
    print("[Auth] capNhatHoTen ERROR: $e");
    rethrow;
  }
}

Future<void> doiMatKhauAuth(String matKhauMoi) async {
  if (matKhauMoi.length < 6) {
    throw Exception("password too short");
  }
  try {
    await supabase.auth.updateUser(
      UserAttributes(password: matKhauMoi),
    );
    print("[Auth] doiMatKhau ok");
  } catch (e) {
    print("[Auth] doiMatKhau ERROR: $e");
    rethrow;
  }
}

Future<sb.User?> getCurrentUser() async {
  return supabase.auth.currentUser;
}

sb.User? getCurrentUserSync() {
  return supabase.auth.currentUser;
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

Future<String?> showConfirmDialog(BuildContext context, String message) async {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Xác nhận"),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, "cancel"),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, "ok"),
            child: Text("Đồng ý"),
          ),
        ],
      );
    },
  );
}

String? layHoTenTuAuthMetadata(Map<String, dynamic>? metadata) {
  if (metadata == null) return null;
  final displayName = metadata['display_name']?.toString();
  if (displayName != null && displayName.isNotEmpty) return displayName;
  final fullName = metadata['full_name']?.toString();
  if (fullName != null && fullName.isNotEmpty) return fullName;
  final hoTen = metadata['hoTen']?.toString();
  if (hoTen != null && hoTen.isNotEmpty) return hoTen;
  final name = metadata['name']?.toString();
  if (name != null && name.isNotEmpty) return name;
  return null;
}

class UserProfile {
  String id;
  String email;
  String? hoTen;

  UserProfile({
    this.id = "",
    this.email = "",
    this.hoTen,
  });

  factory UserProfile.fromAuthUser(sb.User authUser) {
    return UserProfile(
      id: authUser.id,
      email: authUser.email ?? "",
      hoTen: layHoTenTuAuthMetadata(authUser.userMetadata),
    );
  }
}

Future<UserProfile?> getCurrentUserProfile() async {
  final authUser = supabase.auth.currentUser;
  if (authUser == null) return null;
  return UserProfile.fromAuthUser(authUser);
}
