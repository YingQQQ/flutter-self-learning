import 'dart:async';
import 'package:flutter/material.dart';

class ListRefresh extends StatefulWidget {
  final renderItem;
  final requestApi;
  final headerView;

  const ListRefresh([this.requestApi, this.renderItem, this.headerView]);

  @override
  State<StatefulWidget> createState() => _ListRefreshState();
}

class _ListRefreshState extends State<ListRefresh> {
  bool isLoading = false;
  bool _hasMore = true;
  int _pageIndex = 0;
  int _pageTotal = 0;
  List items = [];

  // https://book.flutterchina.club/chapter6/scroll_controller.html
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getMoreData();
    _scrollController.addListener(() {
      // 如果下拉的当前位置到scroll的最下面
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  // 回弹效果
  backElasticEffect() {
//    double edge = 50.0;
//    double offsetFromBottom = _scrollController.position.maxScrollExtent - _scrollController.position.pixels;
//    if (offsetFromBottom < edge) { // 添加一个动画没有更多数据的时候 ListView 向下移动覆盖正在加载更多数据的标志
//      _scrollController.animateTo(
//          _scrollController.offset - (edge -offsetFromBottom),
//          duration: new Duration(milliseconds: 1000),
//          curve: Curves.easeOut);
//    }
  }

  // list探底，执行的具体事件

  _getMoreData() async {
    if (!isLoading && _hasMore) {
      // 如果上一次异步请求数据完成 同时有数据可以加载
      setState(() {
        isLoading = true;
      });

      List newEntries = await mokeHttpRequest();

      _hasMore = (_pageIndex <= _pageTotal);
      // 如果已经挂载
      if (this.mounted) {
        setState(() {
          items.addAll(newEntries);
          isLoading = false;
        });
      }
      backElasticEffect();
    } else if (!isLoading && !_hasMore) {
      // 这样判断,减少以后的绘制
      _pageIndex = 0;
      backElasticEffect();
    }
  }

  // 伪装吐出新数据
  Future<List> mokeHttpRequest() async {
    if (widget.requestApi is Function) {
      final listObj = await widget.requestApi({'pageIndex': _pageIndex});
      _pageIndex = listObj['pageIndex'];
      _pageTotal = listObj['total'];
      return listObj['list'];
    } else {
     return Future.delayed(Duration(seconds: 2), () {
        return [];
      });
    }
  }

  // 下拉加载的事件，清空之前list内容，取前X个其实就是列表重置

  Future<Null> _handleRefresh() async {
    List newEntries = await mokeHttpRequest();
    if (this.mounted) {
      setState(() {
        items.clear();
        items.addAll(newEntries);
        isLoading = false;
        _hasMore = true;
      });
    }
  }

  // 加载中的提示

  Widget _buildLoadText() => Container(
        child: Padding(
          child: Center(
            child: Text('数据没有更多了'),
          ),
          padding: const EdgeInsets.all(18.0),
        ),
      );

  // 上提加载loading的widget,如果数据到达极限，显示没有更多
  Widget _buildProgressIndicator() {
    if (_hasMore) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Opacity(
                opacity: isLoading ? 1.0 : 0.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                '稍等片刻更精彩...',
                style: TextStyle(fontSize: 14.0),
              )
            ],
          ),
        ),
      );
    } else {
      return _buildLoadText();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.builder(
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0 && index != items.length) {
            if (widget.headerView is Function) {
              return widget.headerView();
            } else {
              return Container(
                height: 0,
              );
            }
          }
          if (index == items.length) {
            return _buildProgressIndicator();
          } else {
            if (widget.renderItem is Function) {
              return widget.renderItem(index, items[index]);
            }
          }
        },
        controller: _scrollController,
      ),
      onRefresh: _handleRefresh,
    );
  }
}
