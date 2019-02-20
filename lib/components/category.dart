import 'dart:async';

import 'package:flutter/material.dart';
import '../routers/application.dart';
import '../model/cat.dart';
import '../model/widget.dart';
import '../widgets/index.dart';
import '../components/widget_item_container.dart';

enum CateOrWidgets { Cat, WidgetDemo }

class CategoryHome extends StatefulWidget {
  final String name;
  CategoryHome(this.name);

  @override
  _CategoryHome createState() => new _CategoryHome();
}

class _CategoryHome extends State<CategoryHome> {
  String title = '';
  // 显示列表 cat or widget;
  List<Cat> categories = [];
  List<WidgetPoint> widgetPoints = [];
  List<Cat> catHistory = [];

  CatControlModel catControl = new CatControlModel();
  WidgetControlModel widgetControl = new WidgetControlModel();
  // 所有的可用demos;
  List widgetDemosList = new WidgetDemoList().getDemos();

  @override
  void initState() {
    super.initState();
    getCatByName(widget.name).then((Cat cat) {
      catHistory.add(cat);
      searchCatOrWigdet();
    });
  }

  Future<Cat> getCatByName(String name) async =>
      await catControl.getCatName(name);

  void searchCatOrWigdet() async {
    // 假设进入这个界面的parent一定存在
    Cat parentCat = catHistory.last;

    // 继续搜索显示下一级depth: depth + 1, parentId: parentCat.id
    List<Cat> _categories =
        await catControl.getList(new Cat(parentId: parentCat.id));

    List<WidgetPoint> _widgetPoints = [];

    if (_categories.isEmpty) {
      _widgetPoints =
          await widgetControl.getList(new WidgetPoint(catId: parentCat.id));
    }

    this.setState(() {
      categories = _categories;
      title = parentCat.name;
      widgetPoints = _widgetPoints;
    });
  }

  void onCatgoryTap(Cat cat) {
    go(cat);
  }

  void go(Cat cat) {
    catHistory.add(cat);
    searchCatOrWigdet();
  }

  Future<bool> back() {
    if (catHistory.length == 1) {
      // 返回 Future.value(true); 表示退出.
      return Future<bool>.value(true);
    }

    catHistory.removeLast();
    searchCatOrWigdet();
      // 返回 Future.value(true); 表示不退出.
    return Future<bool>.value(false);
  }

  void onWidgetTap(WidgetPoint widgetPoint) {
    String targetName = widgetPoint.name;
    String targetRouter = '/category/error/404';

    widgetDemosList.forEach((item) {
      if (targetName == item.name) {
        targetRouter = item.routerName;
      }
    });
    Application.router.navigateTo(context, "$targetRouter");
  }

  Widget _buildContent() {
    WidgetItemContainer wiContaienr = WidgetItemContainer(
      columnCount: 3,
      categories: categories,
      isWidgetPoint: false,
    );

    if (widgetPoints.length > 0) {
      wiContaienr = WidgetItemContainer(
          categories: widgetPoints, columnCount: 3, isWidgetPoint: true);
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
      decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage('assets/images/paimaiLogo.png'),
              alignment: Alignment.bottomRight)),
      child: wiContaienr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: WillPopScope(
        onWillPop: () => back(),
        child: ListView(
          children: <Widget>[
            _buildContent()
          ],
        ),
      ),
    );
  }
}
