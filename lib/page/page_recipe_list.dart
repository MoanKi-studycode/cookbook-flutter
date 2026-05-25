import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/recipe_controller.dart';
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
  final TextEditingController txtTim = TextEditingController();

  @override
  void initState() {
    super.initState();
    final ctrl = Get.isRegistered<RecipeController>()
        ? RecipeController.instance
        : Get.put(RecipeController());
    if (widget.idCategory > 0) {
      ctrl.locTheoCategory(widget.idCategory);
    }
  }

  @override
  void dispose() {
    txtTim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tenDanhMuc),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: GetBuilder<RecipeController>(
          id: "recipes",
          builder: (ctrl) {
            if (ctrl.listHienThi.isEmpty && ctrl.mapRecipes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            var list = ctrl.listHienThi;
            final key = txtTim.text.trim().toLowerCase();
            if (key.isNotEmpty) {
              list = list.where((r) => r.ten.toLowerCase().contains(key)).toList();
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: txtTim,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: "Lọc tên món",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("${list.length} món"),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: Text("Không có món"))
                      : ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, i) {
                            return WidgetRecipeCard(recipe: list[i]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
