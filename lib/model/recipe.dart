import 'package:nhom2_flutter_app/helper/supabase_helper.dart';

// TranAnhTin - model Recipe, chuan hoa va hien thi doKho (theo thiet ke CSDL)
int chuanHoaDoKho(int doKho) {
  if (doKho <= 1) return 1;
  if (doKho >= 3) return 3;
  return 2;
}

String getDoKhoText(int doKho) {
  switch (chuanHoaDoKho(doKho)) {
    case 1:
      return "Dễ";
    case 3:
      return "Khó";
    default:
      return "Trung bình";
  }
}

class Recipe {
  int id;
  String ten;
  String moTa;
  String hinhAnh;
  int thoiGian;
  int doKho;
  int idCategory;
  String nguyenLieu;
  String cachLam;

  Recipe({
    this.id = 0,
    this.ten = "",
    this.moTa = "",
    this.hinhAnh = "",
    this.thoiGian = 0,
    this.doKho = 2,
    this.idCategory = 0,
    this.nguyenLieu = "",
    this.cachLam = "",
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    int docDoKho = 2;
    if (map['doKho'] != null) {
      docDoKho = chuanHoaDoKho(int.tryParse(map['doKho'].toString()) ?? 2);
    }

    return Recipe(
      id: int.tryParse(map['id'].toString()) ?? 0,
      ten: map['ten']?.toString() ?? "",
      moTa: map['moTa']?.toString() ?? "",
      hinhAnh: map['hinhAnh']?.toString() ?? "",
      thoiGian: int.tryParse(map['thoiGian'].toString()) ?? 0,
      doKho: docDoKho,
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
      'doKho': doKho,
      'idCategory': idCategory,
      'nguyenLieu': nguyenLieu,
      'cachLam': cachLam,
    };
  }
}

// TranQuocTien - truy van cong thuc tu CSDL, tim kiem theo ten
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
