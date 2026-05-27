import 'package:get/get.dart';
import 'package:nhom2_flutter_app/model/category.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';

class CategoryController extends GetxController {
  List<Category> listCategory = [];
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
      update(["categories"]);

      listCategory = await CategorySnapshot.getListCategory();

      final mapRecipe = await RecipeSnapshot.getMapRecipe();
      soMonTheoDanhMuc = {};

      for (final r in mapRecipe.values) {
        if (r.idCategory > 0) {
          soMonTheoDanhMuc[r.idCategory] =
              (soMonTheoDanhMuc[r.idCategory] ?? 0) + 1;
        }
      }
    } catch (e) {
      errorMessage = "Không tải được danh mục từ Supabase";
      print("[CategoryController] taiDuLieu ERROR: $e");
    } finally {
      isLoading = false;
      update(["categories"]);
    }
  }

  int demMon(int idCategory) {
    return soMonTheoDanhMuc[idCategory] ?? 0;
  }

  Future<void> refreshData() async {
    await taiDuLieu();
  }

  static CategoryController get instance => Get.find<CategoryController>();
}
