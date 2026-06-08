// NguyenThanhThuc - giao dien chinh, bottom nav, layout cac man
// TranQuocTien - hien thi cong thuc, danh muc, loc mon
// TranAnhTin - tab ca nhan, menu tai khoan va ho tro
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/favorite_controller.dart';
import 'package:nhom2_flutter_app/controller/recipe_controller.dart';
import 'package:nhom2_flutter_app/helper/auth_helper.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';
import 'package:nhom2_flutter_app/page/page_account.dart';
import 'package:nhom2_flutter_app/page/page_favorite.dart';
import 'package:nhom2_flutter_app/page/page_help.dart';
import 'package:nhom2_flutter_app/page/page_recipe_detail.dart';
import 'package:nhom2_flutter_app/page/page_search.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  static Color mauChinh = Color(0xFFE85D04);
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RecipeController>()) {
      Get.put(RecipeController());
    }
    if (!Get.isRegistered<FavoriteController>()) {
      Get.put(FavoriteController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _PageHomeTab(),
      PageSearch(),
      PageFavorite(),
      _PageProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: tabIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: BottomNavigationBar(
              currentIndex: tabIndex,
              onTap: (i) => setState(() => tabIndex = i),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              backgroundColor: Colors.white,
              selectedItemColor: mauChinh,
              unselectedItemColor: Colors.grey.shade500,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Trang chủ"),
                BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: "Tìm"),
                BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: "Yêu thích"),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Cá nhân"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHomeTab extends StatefulWidget {
  const _PageHomeTab();

  @override
  State<_PageHomeTab> createState() => _PageHomeTabState();
}

class _PageHomeTabState extends State<_PageHomeTab> {
  static Color mauChinh = Color(0xFFE85D04);
  static Color mauPhu = Color(0xFFFFBA08);
  static Color mauNen = Color(0xFFFFFBF7);

  String tenHienThi = "Bạn";

  @override
  void initState() {
    super.initState();
    taiTen();
  }

  Future<void> taiTen() async {
    final user = await getCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      tenHienThi = user?.hoTen ?? user?.email ?? "Bạn";
    });
  }

  Future<void> _refreshAll() async {
    await RecipeController.instance.refreshData();
    await taiTen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mauNen,
      body: SafeArea(
        child: GetBuilder<RecipeController>(
          builder: (ctrlRecipe) {
            if (ctrlRecipe.isLoading) {
              return _buildLoading("Đang tải dữ liệu...");
            }

            if (ctrlRecipe.errorMessage.isNotEmpty) {
              return _buildError(
                message: ctrlRecipe.errorMessage,
                onRetry: _refreshAll,
              );
            }

            if (ctrlRecipe.mapRecipes.isEmpty && ctrlRecipe.listCategory.isEmpty) {
              return _buildEmpty(
                icon: Icons.cloud_off_rounded,
                message: "Chưa có dữ liệu để hiển thị",
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
                  SizedBox(height: 12),
                  _buildQuickActions(context),
                  SizedBox(height: 22),
                  _sectionTitle(
                    title: "Danh mục",
                    actionText: "Xem tất cả",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PageCategory()),
                    ),
                  ),
                  SizedBox(height: 12),
                  if (ctrlRecipe.listCategory.isEmpty)
                    _smallEmpty("Chưa có danh mục nào")
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: ctrlRecipe.listCategory.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final c = ctrlRecipe.listCategory[i];
                          return _categoryCard(
                            ten: c.ten,
                            soMon: ctrlRecipe.demMon(c.id),
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
                  SizedBox(height: 24),
                  _sectionTitle(
                    title: "Món nổi bật",
                    actionText: "Tất cả món",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PageRecipeList(
                          idCategory: 0,
                          tenDanhMuc: "Tất cả món",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  if (monPhoBien.isEmpty)
                    _smallEmpty("Chưa có món ăn nào")
                  else
                    ...monPhoBien.map((r) => WidgetRecipeCard(recipe: r)),
                  SizedBox(height: 18),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mauChinh, Color(0xFFFF7A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: mauChinh.withOpacity(0.25),
            blurRadius: 18,
            offset: Offset(0, 8),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
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
            child: Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PageSearch()),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFFFFE0C2)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: mauChinh),
              SizedBox(width: 10),
              Text(
                "Tìm món theo tên...",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              Spacer(),
              Icon(Icons.tune_rounded, color: mauChinh),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _quickAction(
              icon: Icons.category_rounded,
              label: "Danh mục",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PageCategory()),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _quickAction(
              icon: Icons.menu_book_rounded,
              label: "Tất cả món",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PageRecipeList(idCategory: 0, tenDanhMuc: "Tất cả món"),
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
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: mauChinh, size: 20),
            SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle({required String title, String? actionText, VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          Spacer(),
          if (actionText != null)
            TextButton(
              onPressed: onTap,
              child: Text(actionText, style: TextStyle(color: mauChinh, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _categoryCard({required String ten, required int soMon, required VoidCallback onTap}) {
    return SizedBox(
      width: 150,
      height: 120,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Color(0xFFFFE0C2)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: mauPhu.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.ramen_dining_rounded, color: mauChinh, size: 22),
              ),
              Spacer(),
              Text(
                ten,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text("$soMon món", style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: mauChinh),
          SizedBox(height: 14),
          Text(message),
        ],
      ),
    );
  }

  Widget _smallEmpty(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18),
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
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Color(0xFFFFEAD6),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 38, color: mauChinh),
            ),
            SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: mauChinh,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => onRetry(),
              icon: Icon(Icons.refresh),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

class PageCategory extends StatelessWidget {
  static Color mauChinh = Color(0xFFE85D04);
  static Color mauNen = Color(0xFFFFFBF7);

  const PageCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mauNen,
      appBar: AppBar(
        title: Text("Danh mục"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: GetBuilder<RecipeController>(
          id: "categories",
          builder: (ctrl) {
            if (ctrl.isLoading) {
              return Center(
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
                "Chưa có danh mục nào",
                "Tải lại",
                ctrl.refreshData,
              );
            }

            return RefreshIndicator(
              onRefresh: ctrl.refreshData,
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 18),
                children: [
                  Container(
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFEAD6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(Icons.restaurant_menu_rounded, color: mauChinh, size: 28),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Khám phá danh mục",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                              SizedBox(height: 4),
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
                  SizedBox(height: 16),
                  ...ctrl.listCategory.map((c) {
                    final soMon = ctrl.demMon(c.id);
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
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
                            padding: EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFF0E6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.ramen_dining_rounded, color: mauChinh),
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.ten,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                      ),
                                      SizedBox(height: 4),
                                      Text("$soMon món", style: TextStyle(color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: mauChinh),
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
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Color(0xFFFFEAD6),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: mauChinh, size: 38),
            ),
            SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            if (buttonText != null && onPressed != null) ...[
              SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mauChinh,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onPressed,
                icon: Icon(Icons.refresh_rounded),
                label: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
  static Color mauChinh = Color(0xFFE85D04);
  static Color mauNen = Color(0xFFFFFBF7);

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            tooltip: "Tải lại",
            onPressed: () => RecipeController.instance.refreshData(),
            icon: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<RecipeController>(
          id: "recipes",
          builder: (ctrl) {
            if (ctrl.isLoading) {
              return Center(
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
                  margin: EdgeInsets.fromLTRB(16, 8, 16, 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
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
                              color: Color(0xFFFFEAD6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.ramen_dining_rounded, color: mauChinh),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.tenDanhMuc,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                      SizedBox(height: 14),
                      TextField(
                        controller: txtTim,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFFFF4EA),
                          labelText: "Lọc theo tên món",
                          hintText: "Nhập tên món trong danh mục này",
                          prefixIcon: Icon(Icons.search_rounded, color: mauChinh),
                          suffixIcon: key.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: _xoaLocTen,
                                  icon: Icon(Icons.close_rounded),
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
                            padding: EdgeInsets.only(bottom: 16),
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
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Color(0xFFFFEAD6),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: mauChinh, size: 38),
            ),
            SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            if (buttonText != null && onPressed != null) ...[
              SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mauChinh,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onPressed,
                icon: Icon(Icons.refresh_rounded),
                label: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
  static Color mauChinh = Color(0xFFE85D04);
  static Color mauNenAnh = Color(0xFFFFF0E6);

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
            : "Không thể hoàn thành yêu cầu. Vui lòng thử lại.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleToggleFavorite() async {
    if (widget.onToggleFavorite != null) {
      widget.onToggleFavorite!();
      await Future.delayed(Duration(milliseconds: 250));
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
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  _buildImage(),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipe.ten,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 7),
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
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _infoChip(Icons.schedule, "${widget.recipe.thoiGian} phút"),
                            _infoChip(Icons.equalizer_rounded, "Độ khó: ${getDoKhoText(widget.recipe.doKho)}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Material(
                    color: isFavorite ? Color(0xFFFFE7E7) : Colors.grey.shade100,
                    shape: CircleBorder(),
                    child: IconButton(
                      tooltip: isFavorite ? "Bỏ yêu thích" : "Yêu thích",
                      icon: dangXuLy
                          ? SizedBox(
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
    return ColoredBox(
      color: mauNenAnh,
      child: Center(
        child: Icon(Icons.restaurant_menu, color: mauChinh, size: 34),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: mauChinh),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PageProfileTab extends StatefulWidget {
  const _PageProfileTab();

  @override
  State<_PageProfileTab> createState() => _PageProfileTabState();
}

class _PageProfileTabState extends State<_PageProfileTab> {
  static Color mauNen = Color(0xFFFFFBF7);

  String ten = "Người dùng";
  String email = "";

  @override
  void initState() {
    super.initState();
    taiProfile();
  }

  Future<void> taiProfile() async {
    final user = await getCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      ten = user?.hoTen ?? "Người dùng";
      email = user?.email ?? "";
    });
  }

  Future<void> dangXuat(BuildContext context) async {
    final String? confirm = await showConfirmDialog(context, "Bạn muốn đăng xuất?");
    if (confirm != "ok") return;
    try {
      await signOutAuth();
    } catch (e) {
      print("[PageProfile] dangXuat ERROR: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể đăng xuất. Vui lòng thử lại.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mauNen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.person, size: 45, color: Colors.grey.shade400),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      ten,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      email.isNotEmpty ? email : "Người yêu ẩm thực",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "CÀI ĐẶT",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 12),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                iconColor: Colors.blue,
                title: "Tài khoản",
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PageAccount()),
                  );
                  await taiProfile();
                },
              ),
              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                iconColor: Colors.green,
                title: "Hỗ trợ & Trợ giúp",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PageHelp()),
                  );
                },
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.04),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: Text(
                    "Đăng xuất",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onTap: () => dangXuat(context),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.black26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }
}
