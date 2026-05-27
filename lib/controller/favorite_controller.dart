import 'package:get/get.dart';
import 'package:nhom2_flutter_app/helper/auth_helper.dart';
import 'package:nhom2_flutter_app/model/favorite.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';

class FavoriteController extends GetxController {
  List<Recipe> listYeuThich = [];
  Set<int> favoriteIds = {};

  bool dangTai = false;
  bool dangXuLy = false;
  String errorMessage = "";

  @override
  void onReady() {
    super.onReady();
    taiYeuThich();
  }

  Future<void> taiYeuThich() async {
    try {
      dangTai = true;
      errorMessage = "";
      update(["favorites"]);

      final userId = getCurrentUserId();
      if (userId == null) {
        listYeuThich = [];
        favoriteIds = {};
        return;
      }

      final favorites = await FavoriteSnapshot.getFavoritesByUser(userId);
      favoriteIds = favorites.map((e) => e.recipeId).toSet();

      final List<Recipe> recipes = [];
      for (final fav in favorites) {
        final recipe = await RecipeSnapshot.getRecipeById(fav.recipeId);
        if (recipe != null) recipes.add(recipe);
      }
      listYeuThich = recipes;
    } catch (e) {
      errorMessage = "Không tải được danh sách yêu thích";
      print("[FavoriteController] taiYeuThich ERROR: $e");
    } finally {
      dangTai = false;
      update(["favorites"]);
      for (final id in favoriteIds) {
        update(["favorite_$id"]);
      }
    }
  }

  Future<int> toggleFavorite(int recipeId) async {
    try {
      dangXuLy = true;
      update(["favorite_$recipeId"]);

      final ketQua = await FavoriteSnapshot.toggleFavorite(recipeId);

      if (ketQua == 1) {
        final dangThich = await FavoriteSnapshot.isFavorite(recipeId);
        if (dangThich) {
          favoriteIds.add(recipeId);
        } else {
          favoriteIds.remove(recipeId);
          listYeuThich.removeWhere((r) => r.id == recipeId);
        }

        await taiYeuThich();
      }

      return ketQua;
    } catch (e) {
      print("[FavoriteController] toggleFavorite ERROR: $e");
      return 0;
    } finally {
      dangXuLy = false;
      update(["favorite_$recipeId", "favorites"]);
    }
  }

  Future<bool> daYeuThich(int recipeId) async {
    if (favoriteIds.contains(recipeId)) return true;

    final userId = getCurrentUserId();
    if (userId == null) return false;

    final fav = await FavoriteSnapshot.findFavorite(userId, recipeId);
    final result = fav != null;
    if (result) favoriteIds.add(recipeId);
    update(["favorite_$recipeId"]);
    return result;
  }

  static FavoriteController get instance => Get.find<FavoriteController>();
}
