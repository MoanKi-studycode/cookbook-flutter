// NguyenThanhThuc - giao dien danh sach yeu thich
// TranQuocTien - FavoriteController, tai du lieu yeu thich
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/favorite_controller.dart';
import 'package:nhom2_flutter_app/helper/auth_helper.dart';
import 'package:nhom2_flutter_app/page/page_home.dart';

class PageFavorite extends StatefulWidget {
  const PageFavorite({super.key});

  @override
  State<PageFavorite> createState() => _PageFavoriteState();
}

class _PageFavoriteState extends State<PageFavorite> {
  static Color mauChinh = Color(0xFFE85D04);
  static Color mauNen = Color(0xFFFFFBF7);

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<FavoriteController>()) {
      Get.put(FavoriteController());
    }
    Future.microtask(() => FavoriteController.instance.taiYeuThich());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mauNen,
      appBar: AppBar(
        title: Text("Món yêu thích"),
        centerTitle: true,
        backgroundColor: mauNen,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            tooltip: "Tải lại",
            icon: Icon(Icons.refresh_rounded),
            onPressed: () => FavoriteController.instance.taiYeuThich(),
          ),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<FavoriteController>(
          id: "favorites",
          builder: (ctrl) {
            if (getCurrentUserId() == null) {
              return _emptyState(
                Icons.lock_outline_rounded,
                "Vui lòng đăng nhập để xem món yêu thích",
                null,
                null,
              );
            }

            if (ctrl.dangTai) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: mauChinh),
                    SizedBox(height: 12),
                    Text("Đang tải món yêu thích..."),
                  ],
                ),
              );
            }

            if (ctrl.errorMessage.isNotEmpty) {
              return _emptyState(
                Icons.error_outline_rounded,
                ctrl.errorMessage,
                "Thử lại",
                ctrl.taiYeuThich,
              );
            }

            if (ctrl.listYeuThich.isEmpty) {
              return RefreshIndicator(
                onRefresh: ctrl.taiYeuThich,
                child: ListView(
                  padding: EdgeInsets.all(24),
                  children: [
                    SizedBox(height: 90),
                    _emptyStateContent(
                      Icons.favorite_border_rounded,
                      "Chưa có món yêu thích",
                      "Bấm biểu tượng trái tim ở món ăn bạn thích. Kéo xuống để tải lại danh sách.",
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: ctrl.taiYeuThich,
              child: ListView(
                padding: EdgeInsets.only(bottom: 16),
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 8, 16, 14),
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF6B6B), mauChinh],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.20),
                          blurRadius: 16,
                          offset: Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(Icons.favorite_rounded, color: Colors.white, size: 30),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bộ sưu tập món ngon",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Bạn đã lưu ${ctrl.listYeuThich.length} món yêu thích",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...ctrl.listYeuThich.map((recipe) {
                    return WidgetRecipeCard(
                      recipe: recipe,
                      daThich: true,
                      onToggleFavorite: () async {
                        final ketQua = await ctrl.toggleFavorite(recipe.id);
                        if (!context.mounted) return;
                        final msg = ketQua == 1
                            ? "Đã bỏ khỏi danh sách yêu thích"
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
                      },
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
            _emptyStateContent(icon, message, null),
            if (buttonText != null && onPressed != null) ...[
              SizedBox(height: 16),
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

  Widget _emptyStateContent(IconData icon, String title, String? subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Color(0xFFFFE7E7),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Icon(icon, size: 44, color: Colors.redAccent),
        ),
        SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.35),
          ),
        ],
      ],
    );
  }
}
