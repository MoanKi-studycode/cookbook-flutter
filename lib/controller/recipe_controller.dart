// TranQuocTien - tai du lieu cong thuc/danh muc tu CSDL, loc theo danh muc, hien thi cho UI
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/model/category.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';

class RecipeController extends GetxController {
  Map<int, Recipe> mapRecipes = {};
  Map<int, Category> mapCategories = {};
  List<Category> listCategory = [];
  List<Recipe> listHienThi = [];
  Map<int, int> soMonTheoDanhMuc = {};

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
      update(["recipes", "categories"]);

      mapRecipes = await RecipeSnapshot.getMapRecipe();
      mapCategories = await CategorySnapshot.getMapCategory();
      listCategory = await CategorySnapshot.getListCategory();

      soMonTheoDanhMuc = {};
      for (final r in mapRecipes.values) {
        if (r.idCategory > 0) {
          soMonTheoDanhMuc[r.idCategory] =
              (soMonTheoDanhMuc[r.idCategory] ?? 0) + 1;
        }
      }
      locDanhSach();
    } catch (e) {
      errorMessage = "Không thể tải dữ liệu";
      print("[RecipeController] taiDuLieu ERROR: $e");
    } finally {
      isLoading = false;
      update(["recipes", "categories"]);
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

  int demMon(int idCategory) {
    return soMonTheoDanhMuc[idCategory] ?? 0;
  }

  Future<void> refreshData() async {
    await taiDuLieu();
  }

  static RecipeController get instance => Get.find<RecipeController>();
}
