import 'package:get/get.dart';
import 'package:nhom2_flutter_app/model/category.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';

class RecipeController extends GetxController {
  Map<int, Recipe> mapRecipes = {};
  Map<int, Category> mapCategories = {};
  List<Recipe> listHienThi = [];

  bool isLoading = false;
  String errorMessage = "";

  @override
  void onReady() {
    super.onReady();
    taiDuLieu();
  }

  Future<void> taiDuLieu() async {
    try {
      isLoading = true;
      errorMessage = "";
      update(["recipes"]);

      mapRecipes = await RecipeSnapshot.getMapRecipe();
      mapCategories = await CategorySnapshot.getMapCategory();
      locDanhSach();
    } catch (e) {
      errorMessage = "Không tải được dữ liệu món ăn từ Supabase";
      print("[RecipeController] taiDuLieu ERROR: $e");
    } finally {
      isLoading = false;
      update(["recipes"]);
    }
  }

  void locDanhSach() {
    listHienThi = mapRecipes.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  void locTheoCategory(int idCategory) {
    if (idCategory == 0) {
      locDanhSach();
      update(["recipes"]);
      return;
    }

    listHienThi = mapRecipes.values
        .where((r) => r.idCategory == idCategory)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    update(["recipes"]);
  }

  String tenCategory(int idCategory) {
    return mapCategories[idCategory]?.ten ?? "Khác";
  }

  Future<void> refreshData() async {
    await taiDuLieu();
  }

  static RecipeController get instance => Get.find<RecipeController>();
}
