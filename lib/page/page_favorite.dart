import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom2_flutter_app/controller/favorite_controller.dart';
import 'package:nhom2_flutter_app/widget/widget_recipe_card.dart';

class PageFavorite extends StatelessWidget {
  const PageFavorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Món yêu thích"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: GetBuilder<FavoriteController>(
          id: "favorites",
          builder: (ctrl) {
            if (ctrl.dangTai) {
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
            if (ctrl.listYeuThich.isEmpty) {
              return const Center(child: Text("Chưa có món yêu thích"));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: ctrl.listYeuThich.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final recipe = ctrl.listYeuThich[i];
                return WidgetRecipeCard(
                  recipe: recipe,
                  daThich: true,
                  onToggleFavorite: () async {
                    await ctrl.toggleFavorite(recipe.id);
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
