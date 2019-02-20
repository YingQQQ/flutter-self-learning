import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/sql.dart';

abstract class WidgetInterface {
  int get id;

  //组件英文名
  String get name;

  //组件中文名
  String get cnName;

  //组件截图
  String get image;

  //组件markdown 文档
  String get doc;

  //类目 id
  int get catId;
}

class WidgetPoint implements WidgetInterface {
  int id;
  //组件英文名
  String name;
  //组件中文名
  String cnName;
  //组件截图
  String image;
  //组件markdown 文档
  String doc;
  //类目 id
  int catId;
  // 路由地址
  String routerName;
  //组件 demo ，多个以 , 分割
  String demo;

  // final 可以调用一次参数
  final WidgetBuilder buildRouter;

  // 初始化参数
  WidgetPoint(
      {this.id,
      this.name,
      this.cnName,
      this.image,
      this.doc,
      this.catId,
      this.routerName,
      this.buildRouter});

  WidgetPoint.fromJSON(Map json)
      : id = json['id'],
        name = json['name'],
        image = json['image'],
        cnName = json['cnName'],
        routerName = json['routerName'],
        doc = json['doc'],
        catId = json['catId'],
        buildRouter = json['buildRouter'];

  String toString() => '(WidgetPoint $name)';

  Object toMap() => {
        'id': id,
        'name': name,
        'cnName': cnName,
        'image': image,
        'doc': doc,
        'catId': catId
      };
  Map toSqlCondition() {
    Map _map = toMap();
    Map condition = {};
    _map.forEach((k, value) {
      if (value != null) {
        condition[k] = value;
      }
    });

    if (condition.isEmpty) {
      return {};
    }

    return condition;
  }
}

class WidgetControlModel  {
  final String table = 'cat';
  Sql sql;

  WidgetControlModel () {
    sql = Sql.setTable(table);
  }

  // 获取WidgetPoint不同深度与parent的列表
  Future<List<WidgetPoint>> getList(WidgetPoint widgetPoint) async {
    // print("cat in getList ${cat.toMap()}");
    List jsonList =
        await sql.getByCondition(conditions: widgetPoint.toSqlCondition());

    List<WidgetPoint> widgets = jsonList.map((json) {
      return new WidgetPoint.fromJSON(json);
    }).toList();
    return widgets;
  }

  // 通过name获取WidgetPoint对象信息
  Future<WidgetPoint> getCatByName(String name) async {
    List json = await sql.getByCondition(conditions: {'name': name});
    if (json.isEmpty) {
      return null;
    }
    return new WidgetPoint.fromJSON(json.first);
  }

  Future<List<WidgetPoint>> search(String name) async {
    List jsonList = await sql.search(conditions: {'name': name});

    if (jsonList.isEmpty) {
      return [];
    }
    List<WidgetPoint> widgets = jsonList.map((json) {
      return new WidgetPoint.fromJSON(json);
    }).toList();
    return widgets;
  }
}
