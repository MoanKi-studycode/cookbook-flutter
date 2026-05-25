import 'package:nhom2_flutter_app/helper/supabase_helper.dart';

class Recipe {
  int id;
  String ten;
  String moTa;
  String hinhAnh;
  int thoiGian;
  double danhGia;
  int idCategory;
  String nguyenLieu;
  String cachLam;

  Recipe({
    this.id = 0,
    this.ten = "",
    this.moTa = "",
    this.hinhAnh = "",
    this.thoiGian = 0,
    this.danhGia = 0,
    this.idCategory = 0,
    this.nguyenLieu = "",
    this.cachLam = "",
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: int.tryParse(map['id'].toString()) ?? 0,
      ten: map['ten']?.toString() ?? "",
      moTa: map['moTa']?.toString() ?? "",
      hinhAnh: map['hinhAnh']?.toString() ?? "",
      thoiGian: int.tryParse(map['thoiGian'].toString()) ?? 0,
      danhGia: double.tryParse(map['danhGia'].toString()) ?? 0,
      idCategory: int.tryParse(map['idCategory'].toString()) ?? 0,
      nguyenLieu: map['nguyenLieu']?.toString() ?? "",
      cachLam: map['cachLam']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ten': ten,
      'moTa': moTa,
      'hinhAnh': hinhAnh,
      'thoiGian': thoiGian,
      'danhGia': danhGia,
      'idCategory': idCategory,
      'nguyenLieu': nguyenLieu,
      'cachLam': cachLam,
    };
  }
}

class RecipeSnapshot {
  static const String table = "Recipe";

  static Future<Map<int, Recipe>> getMapRecipe() {
    return getMapData<Recipe>(
      table: table,
      fromMap: (map) => Recipe.fromMap(map),
      getId: (r) => r.id,
    );
  }

  static Future<Recipe?> getRecipeById(int id) async {
    try {
      final row = await supabase.from(table).select().eq('id', id).maybeSingle();
      if (row == null) return null;
      return Recipe.fromMap(row);
    } catch (e) {
      print("[DB] getRecipeById ERROR: $e");
      return null;
    }
  }

  static Future<List<Recipe>> timKiem(String keyword) async {
    if (keyword.trim().isEmpty) {
      return getListData<Recipe>(
        table: table,
        fromMap: (map) => Recipe.fromMap(map),
      );
    }
    try {
      final rows = await supabase
          .from(table)
          .select()
          .ilike('ten', '%${keyword.trim()}%')
          .order('id');
      return rows.map((row) => Recipe.fromMap(row)).toList();
    } catch (e) {
      print("[DB] timKiem ERROR: $e");
      return [];
    }
  }
}
