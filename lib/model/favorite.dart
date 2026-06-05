import 'package:nhom2_flutter_app/helper/auth_helper.dart';
import 'package:nhom2_flutter_app/helper/supabase_helper.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';

class Favorite {
  int id;
  String userId;
  int recipeId;

  Favorite({
    this.id = 0,
    this.userId = "",
    this.recipeId = 0,
  });

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: int.tryParse(map['id'].toString()) ?? 0,
      userId: map['userId']?.toString() ?? "",
      recipeId: int.tryParse(map['recipeId'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'userId': userId,
      'recipeId': recipeId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'recipeId': recipeId,
    };
  }
}

class FavoriteSnapshot {
  static const String table = "Favorite";

  static Future<List<Favorite>> getFavoritesByUser(String userId) async {
    try {
      final rows = await supabase
          .from(table)
          .select()
          .eq('userId', userId)
          .order('id');

      return rows.map((row) => Favorite.fromMap(row)).toList();
    } catch (e) {
      print("[DB] getFavoritesByUser ERROR: $e");
      return [];
    }
  }

  static Future<List<Favorite>> getFavoritesCurrentUser() async {
    final userId = getCurrentUserId();
    if (userId == null) return [];
    return getFavoritesByUser(userId);
  }

  static Future<List<Recipe>> getRecipeYeuThich() async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    final favorites = await getFavoritesByUser(userId);
    if (favorites.isEmpty) return [];

    final List<Recipe> list = [];
    for (final fav in favorites) {
      final recipe = await RecipeSnapshot.getRecipeById(fav.recipeId);
      if (recipe != null) {
        list.add(recipe);
      }
    }
    return list;
  }

  static Future<Favorite?> findFavorite(String userId, int recipeId) async {
    try {
      final row = await supabase
          .from(table)
          .select()
          .eq('userId', userId)
          .eq('recipeId', recipeId)
          .maybeSingle();

      if (row == null) return null;
      return Favorite.fromMap(row);
    } catch (e) {
      print("[DB] findFavorite ERROR: $e");
      return null;
    }
  }

  static Future<bool> isFavorite(int recipeId) async {
    final userId = getCurrentUserId();
    if (userId == null) return false;

    final fav = await findFavorite(userId, recipeId);
    return fav != null;
  }

  static Future<int> them(Favorite item) async {
    try {
      if (item.userId.trim().isEmpty || item.recipeId <= 0) return 0;

      final existing = await findFavorite(item.userId, item.recipeId);
      if (existing != null) return 1;

      await supabase.from(table).insert(item.toInsertMap());
      return 1;
    } catch (e) {
      print("[DB] Favorite them ERROR: $e");
      return 0;
    }
  }

  static Future<int> xoa(int id) async {
    try {
      if (id <= 0) return 0;
      await supabase.from(table).delete().eq('id', id);
      return 1;
    } catch (e) {
      print("[DB] Favorite xoa ERROR: $e");
      return 0;
    }
  }

  static Future<int> xoaTheoRecipe(int recipeId) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return -1;

      await supabase
          .from(table)
          .delete()
          .eq('userId', userId)
          .eq('recipeId', recipeId);
      return 1;
    } catch (e) {
      print("[DB] Favorite xoaTheoRecipe ERROR: $e");
      return 0;
    }
  }

  static Future<int> toggleFavorite(int recipeId) async {
    final userId = getCurrentUserId();
    if (userId == null) return -1;
    if (recipeId <= 0) return 0;

    final existing = await findFavorite(userId, recipeId);
    if (existing != null) {
      return xoa(existing.id);
    }

    return them(Favorite(userId: userId, recipeId: recipeId));
  }
}
