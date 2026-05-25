import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';
import 'package:nhom2_flutter_app/widget/widget_recipe_card.dart';

class PageSearch extends StatefulWidget {
  const PageSearch({super.key});

  @override
  State<PageSearch> createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  final TextEditingController txtTimKiem = TextEditingController();
  List<Recipe> ketQua = [];
  bool dangTim = false;

  @override
  void dispose() {
    txtTimKiem.dispose();
    super.dispose();
  }

  Future<void> timMon() async {
    setState(() => dangTim = true);
    final list = await RecipeSnapshot.timKiem(txtTimKiem.text);
    if (!mounted) return;
    setState(() {
      ketQua = list;
      dangTim = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm kiếm"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: txtTimKiem,
                decoration: const InputDecoration(
                  labelText: "Tên món",
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (_) => timMon(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: dangTim ? null : timMon,
                child: dangTim
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Tìm"),
              ),
            ),
            Expanded(child: _buildKetQua()),
          ],
        ),
      ),
    );
  }

  Widget _buildKetQua() {
    if (dangTim) {
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
    if (txtTimKiem.text.trim().isEmpty) {
      return const Center(child: Text("Nhập tên món để tìm"));
    }
    if (ketQua.isEmpty) {
      return const Center(child: Text("Không có kết quả"));
    }
    return ListView.separated(
      itemCount: ketQua.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, i) => WidgetRecipeCard(recipe: ketQua[i]),
    );
  }
}
