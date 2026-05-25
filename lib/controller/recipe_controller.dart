import 'package:get/get.dart';
import 'package:nhom2_flutter_app/model/category.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';

class RecipeController extends GetxController {
  Map<int, Recipe> mapRecipes = {};
  Map<int, Category> mapCategories = {};
  List<Recipe> listHienThi = [];

  @override
  void onReady() {
    super.onReady();
    taiDuLieu();
  }

  Future<void> taiDuLieu() async {
    mapRecipes = await RecipeSnapshot.getMapRecipe();
    mapCategories = await CategorySnapshot.getMapCategory();
    locDanhSach();
    update(["recipes"]);
  }

  void locDanhSach() {
    listHienThi = mapRecipes.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  void locTheoCategory(int idCategory) {
    if (idCategory == 0) {
      taiDuLieu();
      return;
    }
    listHienThi = mapRecipes.values
        .where((r) => r.idCategory == idCategory)
        .toList();
    update(["recipes"]);
  }

  String tenCategory(int idCategory) {
    return mapCategories[idCategory]?.ten ?? "Khác";
  }

  static RecipeController get instance => Get.find<RecipeController>();
}
