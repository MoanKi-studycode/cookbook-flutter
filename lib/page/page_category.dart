import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/category_controller.dart';
import 'package:nhom2_flutter_app/page/page_recipe_list.dart';

class PageCategory extends StatelessWidget {
  static const Color mauChinh = Color(0xFFE85D04);
  static const Color mauNen = Color(0xFFFFFBF7);

  const PageCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mauNen,
      appBar: AppBar(
        title: const Text("Danh mục"),
        centerTitle: true,
        backgroundColor: mauNen,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: GetBuilder<CategoryController>(
          id: "categories",
          init: Get.isRegistered<CategoryController>() ? null : CategoryController(),
          builder: (ctrl) {
            if (ctrl.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: mauChinh),
                    SizedBox(height: 12),
                    Text("Đang tải danh mục..."),
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

            if (ctrl.listCategory.isEmpty) {
              return _emptyState(
                Icons.category_outlined,
                "Chưa có danh mục trong Supabase",
                "Tải lại",
                ctrl.refreshData,
              );
            }

            return RefreshIndicator(
              onRefresh: ctrl.refreshData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEAD6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.restaurant_menu_rounded, color: mauChinh, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Khám phá danh mục",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${ctrl.listCategory.length} danh mục món ăn",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...ctrl.listCategory.map((c) {
                    final soMon = ctrl.demMon(c.id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PageRecipeList(
                                  idCategory: c.id,
                                  tenDanhMuc: c.ten,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0E6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.ramen_dining_rounded, color: mauChinh),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.ten,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("$soMon món", style: TextStyle(color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: mauChinh),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
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
