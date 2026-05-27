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
  static const Color mauChinh = Color(0xFFE85D04);
  static const Color mauNen = Color(0xFFFFFBF7);

  Recipe? recipe;
  bool dangTai = true;
  bool dangXuLyYeuThich = false;
  bool daThich = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    taiChiTiet();
  }

  Future<void> taiChiTiet() async {
    try {
      setState(() {
        dangTai = true;
        errorMessage = "";
      });

      if (!Get.isRegistered<FavoriteController>()) {
        Get.put(FavoriteController());
      }

      final r = await RecipeSnapshot.getRecipeById(widget.recipeId);
      final thich = await FavoriteController.instance.daYeuThich(widget.recipeId);

      if (!mounted) return;
      setState(() {
        recipe = r;
        daThich = thich;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => errorMessage = "Không tải được chi tiết món ăn");
      debugPrint("[PageRecipeDetail] taiChiTiet ERROR: $e");
    } finally {
      if (!mounted) return;
      setState(() => dangTai = false);
    }
  }

  Future<void> toggleYeuThich() async {
    if (!Get.isRegistered<FavoriteController>()) {
      Get.put(FavoriteController());
    }

    setState(() => dangXuLyYeuThich = true);

    final ketQua = await FavoriteController.instance.toggleFavorite(widget.recipeId);
    final thichMoi = await FavoriteController.instance.daYeuThich(widget.recipeId);

    if (!mounted) return;
    setState(() {
      daThich = thichMoi;
      dangXuLyYeuThich = false;
    });

    final msg = ketQua == 1
        ? (thichMoi ? "Đã thêm vào yêu thích" : "Đã bỏ khỏi yêu thích")
        : ketQua == -1
            ? "Vui lòng đăng nhập để yêu thích"
            : "Không cập nhật được yêu thích";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String tenCategory() {
    if (recipe == null) return "";
    if (Get.isRegistered<RecipeController>()) {
      return RecipeController.instance.tenCategory(recipe!.idCategory);
    }
    return "Khác";
  }

  @override
  Widget build(BuildContext context) {
    if (dangTai) {
      return Scaffold(
        backgroundColor: mauNen,
        appBar: AppBar(backgroundColor: mauNen, elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: mauChinh)),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: mauNen,
        appBar: AppBar(
          title: const Text("Chi tiết"),
          backgroundColor: mauNen,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        body: _emptyState(Icons.error_outline_rounded, errorMessage, "Thử lại", taiChiTiet),
      );
    }

    if (recipe == null) {
      return Scaffold(
        backgroundColor: mauNen,
        appBar: AppBar(
          title: const Text("Chi tiết"),
          backgroundColor: mauNen,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        body: _emptyState(Icons.no_food_rounded, "Không tìm thấy món ăn", null, null),
      );
    }

    final r = recipe!;
    final listNL = tachDong(r.nguyenLieu);
    final listCL = tachDong(r.cachLam);

    return Scaffold(
      backgroundColor: mauNen,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroImage(r)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.ten,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.15),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _infoChip(Icons.star_rounded, r.danhGia.toStringAsFixed(1)),
                        _infoChip(Icons.schedule_rounded, "${r.thoiGian} phút"),
                        _infoChip(Icons.category_rounded, tenCategory()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: "Mô tả",
                      icon: Icons.notes_rounded,
                      child: Text(
                        r.moTa.isEmpty ? "Chưa có mô tả" : r.moTa,
                        style: TextStyle(color: Colors.grey.shade800, height: 1.45, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _sectionCard(
                      title: "Nguyên liệu",
                      icon: Icons.shopping_basket_rounded,
                      child: listNL.isEmpty
                          ? Text("Chưa có nguyên liệu", style: TextStyle(color: Colors.grey.shade600))
                          : Column(
                              children: listNL.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 3),
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFEAD6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_rounded, size: 14, color: mauChinh),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(e, style: const TextStyle(height: 1.35))),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 14),
                    _sectionCard(
                      title: "Cách làm",
                      icon: Icons.menu_book_rounded,
                      child: listCL.isEmpty
                          ? Text("Chưa có cách làm", style: TextStyle(color: Colors.grey.shade600))
                          : Column(
                              children: List.generate(listCL.length, (i) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: mauChinh,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${i + 1}",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(listCL[i], style: const TextStyle(height: 1.4))),
                                    ],
                                  ),
                                );
                              }),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(Recipe r) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              height: 260,
              width: double.infinity,
              child: r.hinhAnh.trim().isEmpty
                  ? _imageFallback()
                  : Image.network(
                      r.hinhAnh,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _circleButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: daThich ? const Color(0xFFFFE7E7) : Colors.white.withOpacity(0.92),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: daThich ? "Bỏ yêu thích" : "Yêu thích",
                icon: dangXuLyYeuThich
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: mauChinh),
                      )
                    : Icon(
                        daThich ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: daThich ? Colors.redAccent : mauChinh,
                      ),
                onPressed: dangXuLyYeuThich ? null : toggleYeuThich,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 46, height: 46, child: Icon(icon, color: Colors.black87)),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFFFEAD6),
      child: const Center(
        child: Icon(Icons.restaurant_menu_rounded, size: 78, color: mauChinh),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFE0C2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: mauChinh),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAD6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: mauChinh, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _emptyState(IconData icon, String message, String? buttonText, VoidCallback? onPressed) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAD6),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: mauChinh, size: 38),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mauChinh,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onPressed,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
