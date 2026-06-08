// TranAnhTin - ket noi Supabase va helper truy van chung (getMapData, getListData)
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<Map<int, T>> getMapData<T>({
  required String table,
  required T Function(Map<String, dynamic>) fromMap,
  required int Function(T) getId,
  String orderBy = 'id',
}) async {
  try {
    final rows = await supabase.from(table).select().order(orderBy);
    final Map<int, T> result = {};
    for (final row in rows) {
      final item = fromMap(row);
      result[getId(item)] = item;
    }
    return result;
  } catch (e) {
    print("[DB] getMapData ERROR: $e");
    return {};
  }
}

Future<List<T>> getListData<T>({
  required String table,
  required T Function(Map<String, dynamic>) fromMap,
  String orderBy = 'id',
}) async {
  try {
    final rows = await supabase.from(table).select().order(orderBy);
    return rows.map((row) => fromMap(row)).toList();
  } catch (e) {
    print("[DB] getListData ERROR: $e");
    return [];
  }
}
