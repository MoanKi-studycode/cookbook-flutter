import 'package:get/get.dart';
import 'package:nhom2_flutter_app/helper/auth_helper.dart';
import 'package:nhom2_flutter_app/model/favorite.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';

class FavoriteController extends GetxController {
  List<Recipe> listYeuThich = [];
  bool dangTai = false;

  @override
  void onReady() {
    super.onReady();
    taiYeuThich();
  }

  Future<void> taiYeuThich() async {
    dangTai = true;
    update(["favorites"]);
    listYeuThich = await FavoriteSnapshot.getRecipeYeuThich();
    dangTai = false;
    update(["favorites"]);
  }

  Future<int> toggleFavorite(int recipeId) async {
    final ketQua = await FavoriteSnapshot.toggleFavorite(recipeId);
    await taiYeuThich();
    update(["favorites"]);
    return ketQua;
  }

  Future<bool> daYeuThich(int recipeId) async {
    final userId = getCurrentUserId();
    if (userId == null) return false;
    final fav = await FavoriteSnapshot.findFavorite(userId, recipeId);
    return fav != null;
  }

  static FavoriteController get instance => Get.find<FavoriteController>();
}
