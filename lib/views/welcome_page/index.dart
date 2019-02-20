import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import './fourth_page.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key}) : super(key: key);

  @override
  _WelcomePageState createState() {
    return new _WelcomePageState();
  }
}

class _WelcomePageState extends State<WelcomePage> {

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Colors.white,
        child: FourthPage()
    );
  }
}