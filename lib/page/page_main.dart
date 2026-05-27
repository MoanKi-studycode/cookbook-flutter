import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/category_controller.dart';
import 'package:nhom2_flutter_app/controller/favorite_controller.dart';
import 'package:nhom2_flutter_app/controller/recipe_controller.dart';
import 'package:nhom2_flutter_app/page/page_favorite.dart';
import 'package:nhom2_flutter_app/page/page_home.dart';
import 'package:nhom2_flutter_app/page/page_profile.dart';
import 'package:nhom2_flutter_app/page/page_search.dart';

class PageMain extends StatefulWidget {
  const PageMain({super.key});

  @override
  State<PageMain> createState() => _PageMainState();
}

class _PageMainState extends State<PageMain> {
  static const Color mauChinh = Color(0xFFE85D04);
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RecipeController>()) {
      Get.put(RecipeController());
    }
    if (!Get.isRegistered<CategoryController>()) {
      Get.put(CategoryController());
    }
    if (!Get.isRegistered<FavoriteController>()) {
      Get.put(FavoriteController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const PageHome(),
      const PageSearch(),
      const PageFavorite(),
      const PageProfile(),
    ];

    return Scaffold(
      body: IndexedStack(index: tabIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: BottomNavigationBar(
              currentIndex: tabIndex,
              onTap: (i) => setState(() => tabIndex = i),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              backgroundColor: Colors.white,
              selectedItemColor: mauChinh,
              unselectedItemColor: Colors.grey.shade500,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              items: const [
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
