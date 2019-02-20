import './provider.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class BaseModel {
  Database db;
  final String table = '';
  var query;
  BaseModel(this.db) {
    query = db.query;
  }
}

class Sql extends BaseModel {
  final String tableName;

  Sql.setTable(String name)
      : tableName = name,
        super(Provider.db);
  // 获取所有
  Future<List> get() async => await query(tableName);

  String getTableName() => tableName;

  // 删除
  Future<int> delete(String value, String key) async =>
      db.delete(tableName, where: '$key= ?', whereArgs: [value]);

  // 按条件查询
  Future<List> getByCondition({Map<dynamic, dynamic> conditions}) async {
    if (conditions == null || conditions.isEmpty) {
      return get();
    }
    String stringConditions = '';
    int index = 0;

    conditions.forEach((key, value) {
      if (value == null) {
        return;
      }
      if (value.runtimeType == String) {
        stringConditions = '$stringConditions $key = "$value"';
      }
      if (value.runtimeType == int) {
        stringConditions = '$stringConditions $key = "$value"';
      }

      // 拼接查询条件
      if (index >= 0 && index < conditions.length - 1) {
        stringConditions = '$stringConditions  and';
      }
      index++;
    });

    return query(tableName, where: stringConditions);
  }

  // 数据库插入
  Future<Map<String, dynamic>> insert(Map<String, dynamic> json) async {
    var id = await db.insert(tableName, json);
    json['id'] = id;
    return json;
  }

  ///
  /// 搜索
  /// @param Object condition
  /// @mods [And, Or] default is Or
  /// search({'name': "hanxu', 'id': 1};
  ///
  Future<List> search(
      {Map<dynamic, dynamic> conditions, String mods = 'Or'}) async {
    if (conditions == null || conditions.isEmpty) {
      return get();
    }
    String stringConditions = '';
    int index = 0;

    conditions.forEach((key, value) {
      if (value == null) {
        return;
      }
      if (value.runtimeType == String) {
        stringConditions = '$stringConditions $key = "$value"';
      }
      if (value.runtimeType == int) {
        stringConditions = '$stringConditions $key = "$value"';
      }

      // 拼接查询条件
      if (index >= 0 && index < conditions.length - 1) {
        stringConditions = '$stringConditions  $mods';
      }
      index++;
    });

    return query(tableName, where: stringConditions);
  }
}
