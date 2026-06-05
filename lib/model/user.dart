import 'package:nhom2_flutter_app/helper/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

String? layHoTenTuAuthMetadata(Map<String, dynamic>? metadata) {
  if (metadata == null) return null;
  // Display name trong Supabase Auth (user_metadata)
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

class User {
  String id;
  String email;
  String? hoTen;

  User({
    this.id = "",
    this.email = "",
    this.hoTen,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toString() ?? "",
      email: map['email']?.toString() ?? "",
      hoTen: map['hoTen']?.toString(),
    );
  }

  factory User.fromAuthUser(sb.User authUser) {
    return User(
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

class UserSnapshot {
  static const String table = "User";

  static Future<User?> getById(String id) async {
    try {
      final row = await supabase.from(table).select().eq('id', id).maybeSingle();
      if (row == null) return null;
      return User.fromMap(row);
    } catch (e) {
      print("[DB] User getById ERROR: $e");
      return null;
    }
  }

  static Future<int> luuProfile(User user) async {
    try {
      await supabase.from(table).upsert(user.toMap());
      print("[DB] luuProfile ok");
      return 1;
    } catch (e) {
      print("[DB] User luuProfile ERROR: $e");
      return 0;
    }
  }

  static Future<User?> getCurrentUserProfile() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return null;

    final tenAuth = layHoTenTuAuthMetadata(authUser.userMetadata);
    final tuDb = await getById(authUser.id);

    if (tuDb != null && (tuDb.hoTen ?? "").isNotEmpty) {
      return tuDb;
    }

    if (tenAuth != null && tenAuth.isNotEmpty) {
      return User(
        id: authUser.id,
        email: authUser.email ?? "",
        hoTen: tenAuth,
      );
    }

    return User.fromAuthUser(authUser);
  }
}
