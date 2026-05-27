import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/category_controller.dart';
import 'package:nhom2_flutter_app/controller/recipe_controller.dart';
import 'package:nhom2_flutter_app/model/user.dart';
import 'package:nhom2_flutter_app/page/page_category.dart';
import 'package:nhom2_flutter_app/page/page_recipe_list.dart';
import 'package:nhom2_flutter_app/page/page_search.dart';
import 'package:nhom2_flutter_app/widget/widget_recipe_card.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  static const Color mauChinh = Color(0xFFE85D04);
  static const Color mauPhu = Color(0xFFFFBA08);
  static const Color mauNen = Color(0xFFFFFBF7);

  String tenHienThi = "Bạn";

  @override
  void initState() {
    super.initState();
    taiTen();
  }

  Future<void> taiTen() async {
    final user = await UserSnapshot.getCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      tenHienThi = user?.hoTen ?? user?.email ?? "Bạn";
    });
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      RecipeController.instance.refreshData(),
      CategoryController.instance.refreshData(),
    ]);
    await taiTen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mauNen,
      body: SafeArea(
        child: GetBuilder<RecipeController>(
          id: "recipes",
          builder: (ctrlRecipe) {
            return GetBuilder<CategoryController>(
              id: "categories",
              builder: (ctrlCat) {
                if (ctrlRecipe.isLoading || ctrlCat.isLoading) {
                  return _buildLoading("Đang tải dữ liệu từ Supabase...");
                }

                if (ctrlRecipe.errorMessage.isNotEmpty ||
                    ctrlCat.errorMessage.isNotEmpty) {
                  return _buildError(
                    message: ctrlRecipe.errorMessage.isNotEmpty
                        ? ctrlRecipe.errorMessage
                        : ctrlCat.errorMessage,
                    onRetry: _refreshAll,
                  );
                }

                if (ctrlRecipe.mapRecipes.isEmpty && ctrlCat.listCategory.isEmpty) {
                  return _buildEmpty(
                    icon: Icons.cloud_off_rounded,
                    message: "Chưa có dữ liệu món ăn hoặc danh mục trong Supabase.",
                    buttonText: "Tải lại",
                    onRetry: _refreshAll,
                  );
                }

                final monPhoBien = ctrlRecipe.listHienThi.take(6).toList();

                return RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildHeader(),
                      _buildSearchBox(),
                      const SizedBox(height: 12),
                      _buildQuickActions(context),
                      const SizedBox(height: 22),
                      _sectionTitle(
                        title: "Danh mục",
                        actionText: "Xem tất cả",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PageCategory()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (ctrlCat.listCategory.isEmpty)
                        _smallEmpty("Chưa có danh mục trong Supabase")
                      else
                        SizedBox(
                          height: 116,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: ctrlCat.listCategory.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final c = ctrlCat.listCategory[i];
                              return _categoryCard(
                                ten: c.ten,
                                soMon: ctrlCat.demMon(c.id),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PageRecipeList(
                                      idCategory: c.id,
                                      tenDanhMuc: c.ten,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                      _sectionTitle(
                        title: "Món nổi bật",
                        actionText: "Tất cả món",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PageRecipeList(
                              idCategory: 0,
                              tenDanhMuc: "Tất cả món",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (monPhoBien.isEmpty)
                        _smallEmpty("Chưa có món ăn trong Supabase")
                      else
                        ...monPhoBien.map((r) => WidgetRecipeCard(recipe: r)),
                      const SizedBox(height: 18),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [mauChinh, Color(0xFFFF7A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: mauChinh.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Xin chào, $tenHienThi",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Hôm nay bạn muốn nấu món gì?",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PageSearch()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFE0C2)),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: mauChinh),
              const SizedBox(width: 10),
              Text(
                "Tìm món theo tên...",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              const Spacer(),
              const Icon(Icons.tune_rounded, color: mauChinh),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _quickAction(
              icon: Icons.category_rounded,
              label: "Danh mục",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PageCategory())),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _quickAction(
              icon: Icons.menu_book_rounded,
              label: "Tất cả món",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PageRecipeList(idCategory: 0, tenDanhMuc: "Tất cả món"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: mauChinh, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle({required String title, String? actionText, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          if (actionText != null)
            TextButton(
              onPressed: onTap,
              child: Text(actionText, style: const TextStyle(color: mauChinh, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _categoryCard({required String ten, required int soMon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFE0C2)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: mauPhu.withOpacity(0.22),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.ramen_dining_rounded, color: mauChinh),
            ),
            const Spacer(),
            Text(
              ten,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text("$soMon món", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: mauChinh),
          const SizedBox(height: 14),
          Text(message),
        ],
      ),
    );
  }

  Widget _smallEmpty(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildError({required String message, required Future<void> Function() onRetry}) {
    return _buildEmpty(
      icon: Icons.error_outline_rounded,
      message: message,
      buttonText: "Thử lại",
      onRetry: onRetry,
    );
  }

  Widget _buildEmpty({
    required IconData icon,
    required String message,
    required String buttonText,
    required Future<void> Function() onRetry,
  }) {
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
              child: Icon(icon, size: 38, color: mauChinh),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: mauChinh,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
