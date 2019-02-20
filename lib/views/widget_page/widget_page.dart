import 'package:flutter/material.dart';
import '../../components/cate_card.dart';
import '../../model/cat.dart';

class WidgetPage extends StatefulWidget {
  final db;
  final CatControlModel catModel;
  WidgetPage(this.db)
      : catModel = new CatControlModel(),
        super();

  @override
  SecondPageState createState() => new SecondPageState(catModel);
}

class SecondPageState extends State<WidgetPage>
    with AutomaticKeepAliveClientMixin {
  CatControlModel catModel;
  TextEditingController controller;
  String active;
  String data;
  List<Cat> categories = [];

  SecondPageState(this.catModel) : super();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    renderCats();
  }

  void renderCats() async {
    List<Cat> data = await catModel.getList();
    if (data.isNotEmpty) {
      setState(() {
        categories = data;
      });
    }
  }

  Widget buildGrid() {
    // 存放最后widget
    List<Widget> tiles = [];
    for (var item in categories) {
      tiles.add(new CateCard(category: item,));
    }

    return new ListView(
      children: tiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (categories.length == 0) {
      return new ListView(
        children: <Widget>[
          new Container()
        ],
      );
    }

    return new Container(
      color: Theme.of(context).backgroundColor,
      child: buildGrid(),
    );
  }
}
