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
      body: pages[tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex,
        onTap: (i) => setState(() => tabIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Yêu thích"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
        ],
      ),
    );
  }
}
