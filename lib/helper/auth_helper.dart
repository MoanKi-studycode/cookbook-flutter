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
      : layHoTenTuAuthMetadata(authUser.userMetadata);

  final profile = UserProfile(
    id: authUser.id,
    email: authUser.email ?? "",
    hoTen: ten,
  );

  await UserProfileSnapshot.luuProfile(profile);

  if (ten != null && ten.isNotEmpty) {
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
    } catch (e) {
      print("[Auth] updateUser metadata ERROR: $e");
    }
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
    await UserProfileSnapshot.luuProfile(
      UserProfile(
        id: authUser.id,
        email: authUser.email ?? "",
        hoTen: ten,
      ),
    );
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

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? "",
      email: map['email']?.toString() ?? "",
      hoTen: map['hoTen']?.toString(),
    );
  }

  factory UserProfile.fromAuthUser(sb.User authUser) {
    return UserProfile(
      id: authUser.id,
      email: authUser.email ?? "",
      hoTen: layHoTenTuAuthMetadata(authUser.userMetadata),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'hoTen': hoTen,
    };
  }
}

class UserProfileSnapshot {
  static const String table = "User";

  static Future<UserProfile?> getById(String id) async {
    try {
      final row = await supabase.from(table).select().eq('id', id).maybeSingle();
      if (row == null) return null;
      return UserProfile.fromMap(row);
    } catch (e) {
      print("[DB] User getById ERROR: $e");
      return null;
    }
  }

  static Future<int> luuProfile(UserProfile user) async {
    try {
      await supabase.from(table).upsert(user.toMap());
      print("[DB] luuProfile ok");
      return 1;
    } catch (e) {
      print("[DB] User luuProfile ERROR: $e");
      return 0;
    }
  }

  static Future<UserProfile?> getCurrentUserProfile() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return null;

    final tenAuth = layHoTenTuAuthMetadata(authUser.userMetadata);
    final tuDb = await getById(authUser.id);

    if (tuDb != null && (tuDb.hoTen ?? "").isNotEmpty) {
      return tuDb;
    }

    if (tenAuth != null && tenAuth.isNotEmpty) {
      return UserProfile(
        id: authUser.id,
        email: authUser.email ?? "",
        hoTen: tenAuth,
      );
    }

    return UserProfile.fromAuthUser(authUser);
  }
}
