import 'dart:core';
import 'package:flutter/material.dart';
import '../routers/application.dart';
import '../routers/routers.dart';

class ListViewItem extends StatelessWidget {
  final String itemUrl;
  final String itemTitle;
  final String data;

  const ListViewItem({Key key, this.itemUrl, this.itemTitle, this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ListTile(
          onTap: () {
            Application.router.navigateTo(context,
                '${Routes.webViewPage}?title=${Uri.encodeComponent(itemTitle)}&url=${Uri.encodeComponent(itemUrl)}');
          },
          title: Padding(
            child: Text(
              itemTitle,
              style: TextStyle(color: Colors.black, fontSize: 16.0),
            ),
            padding: const EdgeInsets.only(top: 10.0),
          ),
          subtitle: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Text(data,
                    style: TextStyle(color: Colors.black54, fontSize: 10.0)),
              )
            ],
          ),
          trailing:
              Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 30.0),
        ),
      );
}
