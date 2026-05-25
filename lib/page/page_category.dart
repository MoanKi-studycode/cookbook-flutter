import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/category_controller.dart';
import 'package:nhom2_flutter_app/page/page_recipe_list.dart';

class PageCategory extends StatelessWidget {
  const PageCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh mục"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: GetBuilder<CategoryController>(
          id: "categories",
          init: CategoryController(),
          builder: (ctrl) {
            if (ctrl.listCategory.isEmpty) {
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
            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: ctrl.listCategory.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final c = ctrl.listCategory[i];
                final soMon = ctrl.demMon(c.id);
                return ListTile(
                  title: Text(c.ten, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("$soMon món"),
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
              },
            );
          },
        ),
      ),
    );
  }
}
