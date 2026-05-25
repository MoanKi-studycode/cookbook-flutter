import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';
import 'package:nhom2_flutter_app/page/page_recipe_detail.dart';

class WidgetRecipeCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 56,
        height: 56,
        child: Image.network(
          recipe.hinhAnh,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.restaurant),
        ),
      ),
      title: Text(recipe.ten, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("${recipe.thoiGian} phút · ★ ${recipe.danhGia}"),
      trailing: IconButton(
        icon: Icon(
          daThich ? Icons.favorite : Icons.favorite_border,
          color: daThich ? Colors.red : null,
        ),
        onPressed: onToggleFavorite,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PageRecipeDetail(recipeId: recipe.id),
          ),
        );
      },
    );
  }
}
