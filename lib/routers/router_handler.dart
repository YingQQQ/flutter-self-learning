import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import '../components/category.dart';
import '../views/first_page/home.dart';
// import '../components/full_screen_code_dialog.dart'; //全屏弹窗
// import '../widgets/404.dart';
// import '../views/web_page/web_view_page.dart';

// app的首页
var homeHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new AppPage();
  },
);

var categoryHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    String name = params["type"]?.first;

    return new CategoryHome(name);
  },
);