import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../widget_page/widget_page.dart';
import './first_page.dart';
import '../welcome_page/fourth_page.dart';
import '../collection_page/collection_page.dart';
import '../../routers/application.dart';
import '../../utils/provider.dart';
import '../../model/widget.dart';
import '../../widgets/index.dart';
import '../../components/search_input.dart';
import '../../resources/widget_name_to_icon.dart';

const int ThemeColor = 0xFFC91B3A;

class AppPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class  _MyHomePageState extends State<AppPage>
    with SingleTickerProviderStateMixin {
  static List tabData = [
    {'text': '业界动态', 'icon': new Icon(Icons.language)},
    {'text': 'WIDGET', 'icon': new Icon(Icons.extension)},
    {'text': '组件收藏', 'icon': new Icon(Icons.favorite)},
    {'text': '关于手册', 'icon': new Icon(Icons.import_contacts)}
  ];
  WidgetControlModel widgetControl = new WidgetControlModel();
  TabController controller;
  bool isSearch = false;
  String data2ThirdPage = '这是传给ThirdPage的值';
  String appBarTitle = tabData[0]['text'];

  List<Widget> myTabs = [];

  @override
  void initState() {
    super.initState();
    controller = new TabController(initialIndex: 0, length: 4, vsync: this);
    for (var i = 0; i < tabData.length; i++) {
      myTabs.add(new Tab(
        text: tabData[i]['text'],
        icon: tabData[i]['icon'],
      ));
    }
    controller.addListener(() {
      if (controller.indexIsChanging) {
        _onTabChange();
      }
    });
    Application.controller = controller;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var db = Provider.db;
    return new Scaffold(
      appBar: new AppBar(
        title: buildSearchInput(context),
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[
          new FirstPage(),
          new WidgetPage(db),
          new CollectionPage(),
          FourthPage()
        ],
      ),
      bottomNavigationBar: Material(
        color: const Color(0xFFF0EEEF),
        child: SafeArea(
          child: Container(
            height: 65.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFd0d0d0),
                  blurRadius: 3.0,
                  spreadRadius: 2.0,
                  offset: Offset(-1.0, -1.0)
                )
              ]
            ),
            child: TabBar(
              controller: controller,
              indicatorColor: Theme.of(context).primaryColor, // tab标签的下划线颜色
              indicatorWeight: 3.0,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: const Color(0xFF8E8E8E),
              tabs: myTabs,
            ),
          ),
        ),
      ),
    );
  }

  void onWidgetTap(WidgetPoint widgetPoint, BuildContext context) {
    List widgetDemosList = new WidgetDemoList().getDemos();
    String targetName = widgetPoint.name;
    String targetRouter = '/category/error/404';
    widgetDemosList.forEach((item) {
      if (item.name == targetName) {
        targetRouter = item.routerName;
      }
    });
    Application.router.navigateTo(context, "$targetRouter");
  }

  Widget buildSearchInput(BuildContext context) =>
      new SearchInput((value) async {
        if (value != '') {
          List<WidgetPoint> list = await widgetControl.search(value);
          return list
              .map((item) => new MaterialSearchResult<String>(
                    value: item.name,
                    icon: WidgetName2Icon.icons[item.name] ?? null,
                    text: 'widget',
                    onTap: () {
                      onWidgetTap(item, context);
                    },
                  ))
              .toList();
        }
      }, (value) {}, () {});

  void _onTabChange() {
    if (this.mounted) {
      appBarTitle = tabData[controller.index]['text'];
    }
  }
}
