import 'dart:async';
import '../utils/sql.dart';

abstract class CatInterface {
  int get id;
  // 类目名称
  String get name;
  //描述
  String get desc;
  //第几级类目，默认 1
  int get depth;
  //父类目id，没有为 0
  int get parentId;
}

class Cat implements CatInterface {
  int id;
  String name;
  String desc;
  int depth;
  int parentId;

  Cat({this.id, this.name, this.desc, this.depth, this.parentId});

  // 在构造函数体执行之前除了可以调用超类构造函数之外，还可以 初始化实例参数。 使用逗号分隔初始化表达式。
  Cat.fromJSON(Map json)
      : id = json['id'],
        name = json['name'],
        desc = json['desc'],
        depth = json['depth'],
        parentId = json['parentId'];

  String toString() => '(Cat $name)';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'desc': desc,
        'depth': depth,
        'parentId': parentId
      };

  // 过滤条件
  Map toSqlCondition() {
    Map<String, dynamic> _map = toMap();
    Map<String, dynamic> conditions = {};
    _map.forEach((key, value) {
      if (value != null) {
        conditions[key] = value;
      }
    });

    if (conditions.isEmpty) {
      return {};
    }
    return conditions;
  }
}

class CatControlModel {
  final String table = 'cat';
  Sql sql;

  CatControlModel() {
    sql = Sql.setTable(table);
  }
  // 获取一级类目
  Future<List> mainList() async {
    List jsonList = await sql.getByCondition(conditions: {'parentId': 0});
    List<Cat> cats = jsonList.map((cat) => new Cat.fromJSON(cat)).toList();

    return cats;
  }

  // 获取Cat不同深度与parent的列表
  Future<List<Cat>> getList([Cat cat]) async {
    if (cat == null) {
      cat = new Cat(depth: 1, parentId: 0);
    }

    // print("cat in getList ${cat.toMap()}");
    List jsonList = await sql.getByCondition(conditions: cat.toSqlCondition());

    List<Cat> cats = jsonList.map((json) {
      return new Cat.fromJSON(json);
    }).toList();
    return cats;
  }

  // 通过name获取Cat对象信息
  Future<Cat> getCatName(String name) async {
    List jsonList = await sql.getByCondition(conditions: {'name': name});

    if (jsonList.isEmpty) {
      return null;
    }

    return Cat.fromJSON(jsonList.first);
  }
}
