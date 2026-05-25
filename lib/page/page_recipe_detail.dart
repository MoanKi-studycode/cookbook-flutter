import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/favorite_controller.dart';
import 'package:nhom2_flutter_app/controller/recipe_controller.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';

List<String> tachDong(String text) {
  if (text.trim().isEmpty) return [];
  return text
      .split(RegExp(r'[,;\n]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

class PageRecipeDetail extends StatefulWidget {
  final int recipeId;

  const PageRecipeDetail({super.key, required this.recipeId});

  @override
  State<PageRecipeDetail> createState() => _PageRecipeDetailState();
}

class _PageRecipeDetailState extends State<PageRecipeDetail> {
  Recipe? recipe;
  bool dangTai = true;
  bool daThich = false;

  @override
  void initState() {
    super.initState();
    taiChiTiet();
  }

  Future<void> taiChiTiet() async {
    final r = await RecipeSnapshot.getRecipeById(widget.recipeId);
    bool thich = false;
    if (!Get.isRegistered<FavoriteController>()) {
      Get.put(FavoriteController());
    }
    thich = await FavoriteController.instance.daYeuThich(widget.recipeId);
    if (!mounted) return;
    setState(() {
      recipe = r;
      daThich = thich;
      dangTai = false;
    });
  }

  Future<void> toggleYeuThich() async {
    if (!Get.isRegistered<FavoriteController>()) {
      Get.put(FavoriteController());
    }
    final ketQua = await FavoriteController.instance.toggleFavorite(widget.recipeId);
    if (!mounted) return;
    setState(() => daThich = !daThich);
    final msg = ketQua == 1 ? "Đã cập nhật yêu thích" : "Lỗi cập nhật";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  String tenCategory() {
    if (recipe == null) return "";
    if (Get.isRegistered<RecipeController>()) {
      return RecipeController.instance.tenCategory(recipe!.idCategory);
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    if (dangTai) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Chi tiết"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Text("Error!!!", style: TextStyle(color: Colors.red)),
        ),
      );
    }

    final r = recipe!;
    final listNL = tachDong(r.nguyenLieu);
    final listCL = tachDong(r.cachLam);

    return Scaffold(
      appBar: AppBar(
        title: Text(r.ten),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(daThich ? Icons.favorite : Icons.favorite_border, color: Colors.red),
            onPressed: toggleYeuThich,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (r.hinhAnh.isNotEmpty)
                Image.network(
                  r.hinhAnh,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text("No image"),
                ),
              const SizedBox(height: 10),
              Text("★ ${r.danhGia} · ${r.thoiGian} phút · $tenCategory()"),
              const SizedBox(height: 8),
              Text(r.moTa.isEmpty ? "Chưa có mô tả" : r.moTa),
              const Divider(thickness: 2),
              const Text("Nguyên liệu", style: TextStyle(fontWeight: FontWeight.bold)),
              ...listNL.map((e) => ListTile(dense: true, title: Text("• $e"))),
              const Divider(thickness: 2),
              const Text("Cách làm", style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate(listCL.length, (i) {
                return ListTile(
                  dense: true,
                  leading: Text("${i + 1}."),
                  title: Text(listCL[i]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
