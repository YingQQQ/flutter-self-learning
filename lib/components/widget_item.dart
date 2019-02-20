import 'package:flutter/material.dart';
import '../utils/style.dart';
import '../resources/widget_name_to_icon.dart';

String _widgetName;

// StatelessWidget 无状态组件
class WidgetItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  //用于计算border
  final int index;
  final int totalCount;
  // row 行的长度
  final int rowLength;
  final String textSize;

  WidgetItem(
      {this.title,
      this.onTap,
      this.index,
      this.totalCount,
      this.rowLength,
      this.textSize});
  Border _buildBorder(context) {
    Border _border;
    //是不是最右边的,决定是否有右侧边框, % ==> 取模
    bool isRight = (index % rowLength) == (rowLength - 1);
    var currentRow = (index + 1) % rowLength > 0
        ? (index + 1) ~/ rowLength + 1
        : totalCount ~/ rowLength;
    int totalRow = totalCount % rowLength > 0
        ? totalCount ~/ rowLength + 1
        : totalCount ~/ rowLength;
    if (currentRow < totalRow && isRight) {
      //不是最后一行并且是最右边
      _border = Border(
        bottom: const BorderSide(
            width: 1.0, color: Color(WidgetDemoColor.borderColor)),
      );
    }

    if (currentRow < totalRow && !isRight) {
      _border = Border(
        right: const BorderSide(
            width: 1.0, color: Color(WidgetDemoColor.borderColor)),
        bottom: const BorderSide(
            width: 1.0, color: Color(WidgetDemoColor.borderColor)),
      );
    }

    if (currentRow == totalRow && !isRight) {
      _border = Border(
        right: const BorderSide(
            width: 1.0, color: Color(WidgetDemoColor.borderColor)),
      );
    }
    return _border;
  }

  @override
  Widget build(BuildContext context) {
    //首字母转为大写
    _widgetName = title.replaceFirst(
        title.substring(0, 1), title.substring(0, 1).toLowerCase());
    Icon widgetIcon;

    if (WidgetName2Icon.icons[_widgetName] != null) {
      widgetIcon = Icon(WidgetName2Icon.icons[_widgetName]);
    } else {
      widgetIcon = Icon(
        Icons.crop,
      );
    }

    final textStyle = (textSize == 'middle')
        ? TextStyle(fontSize: 13.8, fontFamily: 'MediumItalic')
        : TextStyle(fontSize: 16.0);
    // https://flutterchina.club/gestures/
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: new BoxDecoration(border: _buildBorder(context)),
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
        height: 150,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              widgetIcon,
              SizedBox(
                height: 8.0,
              ),
              Text(
                _widgetName,
                style: textStyle,
              )
            ]),
      ),
    );
  }
}
