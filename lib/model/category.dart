import 'package:nhom2_flutter_app/helper/supabase_helper.dart';

class Category {
  int id;
  String ten;
  String? moTa;

  Category({
    this.id = 0,
    this.ten = "",
    this.moTa,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: int.tryParse(map['id'].toString()) ?? 0,
      ten: map['ten']?.toString() ?? "",
      moTa: map['moTa']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ten': ten,
      'moTa': moTa,
    };
  }
}

class CategorySnapshot {
  static const String table = "Category";

  static Future<Map<int, Category>> getMapCategory() {
    return getMapData<Category>(
      table: table,
      fromMap: (map) => Category.fromMap(map),
      getId: (c) => c.id,
    );
  }

  static Future<List<Category>> getListCategory() {
    return getListData<Category>(
      table: table,
      fromMap: (map) => Category.fromMap(map),
    );
  }
}
