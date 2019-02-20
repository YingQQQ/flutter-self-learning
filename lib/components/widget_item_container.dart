import 'package:flutter/material.dart';
import './widget_item.dart';
import '../routers/application.dart';
import '../widgets/index.dart';

class WidgetItemContainer extends StatelessWidget {
  final List<dynamic> categories;
  final int columnCount; //一行几个
  final bool isWidgetPoint;

  // 所有的可用demos;
  final List widgetDemosList = new WidgetDemoList().getDemos();

  WidgetItemContainer(
      {Key key,
      @required this.categories,
      @required this.columnCount,
      @required this.isWidgetPoint})
      : super(key: key);

  List<Widget> _buildColumns(context) {
    List<Widget> _listWidget = [];
    List<Widget> _listRows = [];

    int addI;
    for (var i = 0, length = categories.length; i < length; i += columnCount) {
      _listRows = [];
      for (int innerI = 0; innerI < columnCount; innerI++) {
        addI = innerI + i;
        if (addI < length) {
          dynamic item = categories[addI];
          _listRows.add(Expanded(
            child: WidgetItem(
              title: item.name,
              onTap: () {
                if (isWidgetPoint) {
                  String targeName = item.name;
                  String targetRouter = '/category/error/404';
                  widgetDemosList.forEach((item) {
                    if (item.name == targeName) {
                      targetRouter = item.routerName;
                    }
                  });
                  Application.router.navigateTo(context, "$targetRouter");
                } else {
                  Application.router
                      .navigateTo(context, "/category/${item.name}");
                }
              },
              index: addI,
              totalCount: length,
              rowLength: columnCount,
              textSize: isWidgetPoint ? 'middle' : 'small',
            ),
            flex: 1,
          ));
        } else {
          _listRows.add(
            Expanded(
              flex: 1,
              child: Container(),
            ),
          );
        }
      }
      _listWidget.add(
        Row(
          children: _listRows,
        ),
      );
    }

    return _listWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildColumns(context),
    );
  }
}
