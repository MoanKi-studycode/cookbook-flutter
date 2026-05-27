import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nhom2_flutter_app/model/recipe.dart';
import 'package:nhom2_flutter_app/widget/widget_recipe_card.dart';

class PageSearch extends StatefulWidget {
  const PageSearch({super.key});

  @override
  State<PageSearch> createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  static const Color mauChinh = Color(0xFFE85D04);
  static const Color mauNen = Color(0xFFFFFBF7);

  final TextEditingController txtTimKiem = TextEditingController();

  List<Recipe> ketQua = [];
  bool dangTim = false;
  bool daTimLanDau = false;
  String loi = "";
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    txtTimKiem.dispose();
    super.dispose();
  }

  void _timTuDong(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      timMon();
    });
  }

  Future<void> timMon() async {
    final keyword = txtTimKiem.text.trim();

    if (keyword.isEmpty) {
      setState(() {
        ketQua = [];
        dangTim = false;
        daTimLanDau = false;
        loi = "";
      });
      return;
    }

    setState(() {
      dangTim = true;
      daTimLanDau = true;
      loi = "";
    });

    try {
      final list = await RecipeSnapshot.timKiem(keyword);
      if (!mounted) return;
      setState(() {
        ketQua = list;
        dangTim = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        ketQua = [];
        dangTim = false;
        loi = "Không tìm kiếm được món ăn. Vui lòng thử lại.";
      });
      debugPrint("[PageSearch] timMon ERROR: $e");
    }
  }

  void xoaTuKhoa() {
    txtTimKiem.clear();
    _debounce?.cancel();
    setState(() {
      ketQua = [];
      dangTim = false;
      daTimLanDau = false;
      loi = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyword = txtTimKiem.text.trim();

    return Scaffold(
      backgroundColor: mauNen,
      appBar: AppBar(
        title: const Text("Tìm kiếm món ăn"),
        centerTitle: true,
        backgroundColor: mauNen,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bạn đang tìm món gì?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Nhập tên món ăn, app sẽ tìm trực tiếp từ Supabase.",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: txtTimKiem,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4EA),
                      labelText: "Nhập tên món ăn",
                      hintText: "Ví dụ: bò, gà, bánh...",
                      prefixIcon: const Icon(Icons.search_rounded, color: mauChinh),
                      suffixIcon: keyword.isEmpty
                          ? null
                          : IconButton(
                              onPressed: xoaTuKhoa,
                              icon: const Icon(Icons.close_rounded),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _timTuDong(value);
                    },
                    onSubmitted: (_) => timMon(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mauChinh,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: dangTim ? null : timMon,
                      icon: dangTim
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.search_rounded),
                      label: Text(dangTim ? "Đang tìm..." : "Tìm món"),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildKetQua()),
          ],
        ),
      ),
    );
  }

  Widget _buildKetQua() {
    final keyword = txtTimKiem.text.trim();

    if (dangTim) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: mauChinh),
            SizedBox(height: 12),
            Text("Đang tìm kiếm..."),
          ],
        ),
      );
    }

    if (loi.isNotEmpty) {
      return _emptyState(Icons.error_outline_rounded, loi, "Thử lại", timMon);
    }

    if (keyword.isEmpty) {
      return _emptyState(
        Icons.manage_search_rounded,
        "Nhập tên món ăn để bắt đầu tìm kiếm.",
        null,
        null,
      );
    }

    if (daTimLanDau && ketQua.isEmpty) {
      return _emptyState(
        Icons.search_off_rounded,
        "Không tìm thấy món ăn có tên chứa '$keyword'.",
        null,
        null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
          child: Row(
            children: [
              const Text(
                "Kết quả",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAD6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "${ketQua.length} món",
                  style: const TextStyle(color: mauChinh, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: ketQua.length,
            itemBuilder: (context, i) => WidgetRecipeCard(recipe: ketQua[i]),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(IconData icon, String message, String? buttonText, VoidCallback? onPressed) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAD6),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: mauChinh, size: 38),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mauChinh,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onPressed,
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
