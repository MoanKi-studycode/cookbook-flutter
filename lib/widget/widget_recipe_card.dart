import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/favorite_controller.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';
import 'package:nhom2_flutter_app/page/page_recipe_detail.dart';

class WidgetRecipeCard extends StatefulWidget {
  final Recipe recipe;
  final bool daThich;
  final VoidCallback? onToggleFavorite;

  const WidgetRecipeCard({
    super.key,
    required this.recipe,
    this.daThich = false,
    this.onToggleFavorite,
  });

  @override
  State<WidgetRecipeCard> createState() => _WidgetRecipeCardState();
}

class _WidgetRecipeCardState extends State<WidgetRecipeCard> {
  static const Color mauChinh = Color(0xFFE85D04);
  static const Color mauNenAnh = Color(0xFFFFF0E6);

  bool daThich = false;
  bool dangXuLy = false;

  @override
  void initState() {
    super.initState();
    daThich = widget.daThich;
    _taiTrangThaiYeuThich();
  }

  Future<void> _taiTrangThaiYeuThich() async {
    if (!Get.isRegistered<FavoriteController>()) {
      Get.put(FavoriteController());
    }

    final result = await FavoriteController.instance.daYeuThich(widget.recipe.id);
    if (!mounted) return;
    setState(() => daThich = result);
  }

  Future<void> _toggleFavoriteMacDinh() async {
    if (!Get.isRegistered<FavoriteController>()) {
      Get.put(FavoriteController());
    }

    setState(() => dangXuLy = true);
    final ketQua = await FavoriteController.instance.toggleFavorite(widget.recipe.id);
    final result = await FavoriteController.instance.daYeuThich(widget.recipe.id);

    if (!mounted) return;
    setState(() {
      daThich = result;
      dangXuLy = false;
    });

    final msg = ketQua == 1
        ? (result ? "Đã thêm vào yêu thích" : "Đã bỏ khỏi yêu thích")
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

  Future<void> _handleToggleFavorite() async {
    if (widget.onToggleFavorite != null) {
      widget.onToggleFavorite!();
      await Future.delayed(const Duration(milliseconds: 250));
      await _taiTrangThaiYeuThich();
      return;
    }

    await _toggleFavoriteMacDinh();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavoriteController>(
      id: "favorite_${widget.recipe.id}",
      builder: (_) {
        final ctrl = Get.isRegistered<FavoriteController>()
            ? FavoriteController.instance
            : null;
        final isFavorite = ctrl?.favoriteIds.contains(widget.recipe.id) ?? daThich;

        return Card(
          elevation: 1.5,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PageRecipeDetail(recipeId: widget.recipe.id),
                ),
              );
              await _taiTrangThaiYeuThich();
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  _buildImage(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipe.ten,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          widget.recipe.moTa.isEmpty
                              ? "Món ngon mỗi ngày"
                              : widget.recipe.moTa,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _infoChip(Icons.schedule, "${widget.recipe.thoiGian} phút"),
                            _infoChip(Icons.star_rounded, widget.recipe.danhGia.toStringAsFixed(1)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: isFavorite ? const Color(0xFFFFE7E7) : Colors.grey.shade100,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: isFavorite ? "Bỏ yêu thích" : "Yêu thích",
                      icon: dangXuLy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.redAccent : Colors.grey.shade700,
                            ),
                      onPressed: dangXuLy ? null : _handleToggleFavorite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 92,
        height: 92,
        child: widget.recipe.hinhAnh.trim().isEmpty
            ? _imageFallback()
            : Image.network(
                widget.recipe.hinhAnh,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imageFallback(),
              ),
      ),
    );
  }

  Widget _imageFallback() {
    return const ColoredBox(
      color: mauNenAnh,
      child: Center(
        child: Icon(Icons.restaurant_menu, color: mauChinh, size: 34),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: mauChinh),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
