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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CookBook"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: GetBuilder<RecipeController>(
          id: "recipes",
          builder: (ctrlRecipe) {
            return GetBuilder<CategoryController>(
              id: "categories",
              builder: (ctrlCat) {
                if (ctrlRecipe.listHienThi.isEmpty && ctrlRecipe.mapRecipes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Loading..."),
                      ],
                    ),
                  );
                }

                final monPhoBien = ctrlRecipe.listHienThi.take(6).toList();

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    Text(
                      "Xin chào, $tenHienThi",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    _buildMenuBtn(context, "Danh mục món", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PageCategory()),
                      );
                    }),
                    _buildMenuBtn(context, "Tìm kiếm", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PageSearch()),
                      );
                    }),
                    _buildMenuBtn(context, "Tất cả món", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PageRecipeList(
                            idCategory: 0,
                            tenDanhMuc: "Tất cả món",
                          ),
                        ),
                      );
                    }),
                    const Divider(thickness: 2),
                    const Text("Danh mục", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    ...ctrlCat.listCategory.map((c) {
                      return ListTile(
                        title: Text(c.ten),
                        subtitle: Text("${ctrlCat.demMon(c.id)} món"),
                        trailing: const Icon(Icons.chevron_right),
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
                      );
                    }),
                    const Divider(thickness: 2),
                    const Text("Món phổ biến", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...monPhoBien.map((r) => WidgetRecipeCard(recipe: r)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuBtn(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(onPressed: onTap, child: Text(label)),
      ),
    );
  }
}
