import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/net_utils.dart';
import '../../components/list_view_item.dart';
import '../../components/list_refresh.dart' as listComp;
import '../../components/pagination.dart';
import './first_page_item.dart';
import '../../components/disclaimer_msg.dart';

GlobalKey<DisclaimerMsgState> key;

class FirstPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage>
    with AutomaticKeepAliveClientMixin {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<bool> _unKnow;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (key == null) {
      key = GlobalKey();
      _unKnow = _prefs.then((SharedPreferences prefs) {
        return (prefs.getBool('disclaimer::Boolean') ?? false);
      });
      // 判断是否需要弹出免责声明,已经勾选过不在显示,就不会主动弹
      _unKnow.then((bool value) {
        new Future.delayed(const Duration(seconds: 1), () {
          if (!value) {
            key.currentState.showAlertDialog(context);
          }
        });
      });
    }
  }

  Future<Map> getIndexListData([Map<String, dynamic> params]) async {
    const juejin_flutter =
        'https://timeline-merger-ms.juejin.im/v1/get_tag_entry?src=web&tagId=5a96291f6fb9a0535b535438';
    int pageIndex = (params is Map) ? params['pageIndex'] : 0;
    final Map<String, dynamic> _param = {
      'page': pageIndex,
      'pageSize': 20,
      'sort': 'rankIndex'
    };
    List responseList = [];
    int pageTotal = 0;

    try {
      var response = await NetUtils.get(juejin_flutter, params: _param);
      responseList = response['d']['entrylist'];
      pageTotal = response['d']['total'];
      if (!(pageTotal is int) || pageTotal <= 0) {
        pageTotal = 0;
      }
    } catch (e) {}

    pageIndex += 1;

    List resultList = [];
    for (var i = 0; i < responseList.length; i++) {
      try {
        FirstPageItem cellData = FirstPageItem.fromJson(responseList[i]);
        resultList.add(cellData);
      } catch (e) {}
    }
    Map<String, dynamic> result = {
      "list": resultList,
      'total': pageTotal,
      'pageIndex': pageIndex
    };
    return result;
  }

  Widget makeCard(index, item) {
    var myTitle = '${item.title}';
    var myUsername = '${'👲'}: ${item.username} ';
    var codeUrl = '${item.detailUrl}';
    return new ListViewItem(
      itemUrl: codeUrl,
      itemTitle: myTitle,
      data: myUsername,
    );
  }

  Widget headerView() => Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Pagination(),
              Positioned(
                top: 10.0,
                left: 10.0,
                child: DisclaimerMsg(key: key, pWidget: this),
              ),
            ],
          ),
          SizedBox(
            height: 1,
            child: Container(
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      );
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        Expanded(
          child: listComp.ListRefresh(getIndexListData,makeCard,headerView),
        )
      ],
    );
  }
}
