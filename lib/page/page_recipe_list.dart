import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/recipe_controller.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';
import 'package:nhom2_flutter_app/widget/widget_recipe_card.dart';

class PageRecipeList extends StatefulWidget {
  final int idCategory;
  final String tenDanhMuc;

  const PageRecipeList({
    super.key,
    required this.idCategory,
    required this.tenDanhMuc,
  });

  @override
  State<PageRecipeList> createState() => _PageRecipeListState();
}

class _PageRecipeListState extends State<PageRecipeList> {
  static const Color mauChinh = Color(0xFFE85D04);
  static const Color mauNen = Color(0xFFFFFBF7);

  final TextEditingController txtTim = TextEditingController();

  @override
  void initState() {
    super.initState();
    final ctrl = Get.isRegistered<RecipeController>()
        ? RecipeController.instance
        : Get.put(RecipeController());

    if (ctrl.mapRecipes.isEmpty && !ctrl.isLoading) {
      ctrl.taiDuLieu();
    }
  }

  @override
  void dispose() {
    txtTim.dispose();
    super.dispose();
  }

  List<Recipe> _locMon(List<Recipe> input) {
    Iterable<Recipe> list = input;

    if (widget.idCategory > 0) {
      list = list.where((r) => r.idCategory == widget.idCategory);
    }

    final key = txtTim.text.trim().toLowerCase();
    if (key.isNotEmpty) {
      list = list.where((r) => r.ten.toLowerCase().contains(key));
    }

    final result = list.toList()..sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  void _xoaLocTen() {
    txtTim.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mauNen,
      appBar: AppBar(
        title: Text(widget.tenDanhMuc),
        centerTitle: true,
        backgroundColor: mauNen,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            tooltip: "Tải lại",
            onPressed: () => RecipeController.instance.refreshData(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<RecipeController>(
          id: "recipes",
          builder: (ctrl) {
            if (ctrl.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: mauChinh),
                    SizedBox(height: 12),
                    Text("Đang tải danh sách món..."),
                  ],
                ),
              );
            }

            if (ctrl.errorMessage.isNotEmpty) {
              return _emptyState(
                Icons.error_outline_rounded,
                ctrl.errorMessage,
                "Thử lại",
                ctrl.refreshData,
              );
            }

            final tatCaMon = ctrl.mapRecipes.values.toList();
            final list = _locMon(tatCaMon);
            final key = txtTim.text.trim();

            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEAD6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.ramen_dining_rounded, color: mauChinh),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.tenDanhMuc,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Đang hiển thị ${list.length} món",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: txtTim,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFFF4EA),
                          labelText: "Lọc theo tên món",
                          hintText: "Nhập tên món trong danh mục này",
                          prefixIcon: const Icon(Icons.search_rounded, color: mauChinh),
                          suffixIcon: key.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: _xoaLocTen,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? _emptyState(
                          Icons.no_food_rounded,
                          key.isEmpty
                              ? "Không có món ăn trong danh mục này."
                              : "Không có món nào khớp với '$key'.",
                          null,
                          null,
                        )
                      : RefreshIndicator(
                          onRefresh: ctrl.refreshData,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: list.length,
                            itemBuilder: (context, i) => WidgetRecipeCard(recipe: list[i]),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
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
