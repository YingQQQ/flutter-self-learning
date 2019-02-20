import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef String FormFieldFormatter<T>(T v);
typedef bool MaterialSearchFilter<T>(T v, String c);
typedef int MaterialSearchSort<T>(T a, T b, String c);
typedef Future<List<MaterialSearchResult>> MaterialResultsFinder(String c);
typedef void OnSubmit(String value);

class MaterialSearchResult<T> extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  final String text;
  final IconData icon;

  const MaterialSearchResult(
      {Key key, this.value, this.text, this.icon, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onTap,
      child: new Container(
        height: 64.0,
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
        child: new Row(
          children: <Widget>[
            new Container(
                  width: 30.0,
                  margin: const EdgeInsets.only(right: 10.0),
                  child: new Icon(icon),
                ) ??
                null,
            new Expanded(
              child: new Text(
                value,
                style: Theme.of(context).textTheme.subhead,
              ),
            ),
            new Text(text, style: Theme.of(context).textTheme.subhead)
          ],
        ),
      ),
    );
  }
}

class MaterialSearch<T> extends StatefulWidget {
  final String placeholder;
  final List<MaterialSearchResult<T>> results;
  final MaterialResultsFinder getResults;
  final MaterialSearchFilter<T> filter;
  final MaterialSearchSort<T> sort;
  final int limit;
  final ValueChanged<T> onSelect;
  final OnSubmit onSubmit;
  final Color barBackgroundColor;
  final Color iconColor;
  final Widget leading;

  MaterialSearch(
      {Key key,
      this.placeholder,
      this.results,
      this.getResults,
      this.filter,
      this.sort,
      this.limit: 10,
      this.onSelect,
      this.onSubmit,
      this.barBackgroundColor: Colors.white,
      this.iconColor: Colors.black,
      this.leading})
      : assert(() {
          if (results == null && getResults == null ||
              results != null && getResults != null) {
            throw new AssertionError(
                'Either provide a function to get the results, or the results.');
          }

          return true;
        }()),
        super(key: key);

  @override
  _MaterialSearchState<T> createState() => _MaterialSearchState<T>();
}

class _MaterialSearchState<T> extends State<MaterialSearch> {
  bool _loading = false;
  List<MaterialSearchResult<T>> _results = [];
  Timer _resultsTimer;

  String _criteria = '';
  TextEditingController _controller = TextEditingController();

  _filter(dynamic v, String c) => v
      .toString()
      .toLowerCase()
      .trim()
      .contains(new RegExp(r'' + c.toLowerCase().trim() + ''));

  Future _getResultsDebounced() async {
    if (_results.length == 0) {
      setState(() {
        _loading = true;
      });
    }

    if (_resultsTimer != null && _resultsTimer.isActive) {
      _resultsTimer.cancel();
    }

    _resultsTimer = new Timer(new Duration(milliseconds: 400), () async {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = true;
      });

      var results = await widget.getResults(_criteria);

      if (!mounted) {
        return;
      }
      if (results != null) {
        setState(() {
          _loading = false;
          _results = results;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.getResults != null) {
      _getResultsDebounced();
    }
    _controller.addListener(() {
      setState(() {
        _criteria = _controller.value.text;
        if (widget.getResults != null) {
          _getResultsDebounced();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _resultsTimer?.cancel();
  }

  Widget buildBody(List results) {
    if (_criteria.isEmpty) {
      return History();
    } else if (_loading) {
      return new Center(
        child: new Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator(),
        ),
      );
    }

    if (_criteria.isNotEmpty) {
      return new SingleChildScrollView(
        child: new Column(
          children: results,
        ),
      );
    }
    return new Text('暂无数据');
  }

  @override
  Widget build(BuildContext context) {
    // expr1 ?? expr2
    //如果 expr1 是 non-null，返回其值； 否则执行 expr2 并返回其结果。
    var results = (widget.results ?? _results).where((result) {
      if (widget.filter != null) {
        return _filter(result.value, _criteria);
      }

      return true;
    }).toList();

    if (widget.sort != null) {
      results.sort((a, b) => widget.sort(a.value, b.value, _criteria));
    }

    results = results.take(widget.limit).toList();

    //为Icon自定义颜色（固定为黑色)
    IconThemeData iconTheme =
        Theme.of(context).iconTheme.copyWith(color: widget.iconColor);

    return new Scaffold(
      appBar: new AppBar(
        leading: widget.leading,
        backgroundColor: widget.barBackgroundColor,
        iconTheme: iconTheme,
        // 输入框及表单
        title: new TextField(
          controller: _controller,
          autofocus: true,
          decoration: new InputDecoration.collapsed(
              // 用于控制TextField的外观显示，如提示文本、背景颜色、边框等
              hintText: widget.placeholder),
          style: Theme.of(context).textTheme.title,
          // 输入框输入完成时触发
          onSubmitted: (String value) {
            if (widget.onSubmit != null) {
              widget.onSubmit(value);
            }
          },
        ),
        actions: _criteria.length == 0
            ? <Widget>[]
            : <Widget>[
                new IconButton(
                  icon: new Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _controller.text = _criteria = '';
                    });
                  },
                )
              ],
      ),
      body: buildBody(results),
    );
  }
}

// https://docs.flutter.io/flutter/material/MaterialPageRoute/MaterialPageRoute.html
class _MaterialSearchPageRoute<T> extends MaterialPageRoute<T> {
  _MaterialSearchPageRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool maintainState: true,
    bool fullscreenDialog: false,
  })  : assert(builder != null),
        super(
            builder: builder,
            settings: settings,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog);
}

// https://book.flutterchina.club/chapter3/input_and_form.html
class MaterialSearchInput<T> extends StatefulWidget {
  //保存回调
  final FormFieldSetter<T> onSaved;
  //验证回调
  final FormFieldValidator<T> validator;
  //是否自动校验。
  final bool autovalidate;

  final String placeholder;

  final FormFieldFormatter<T> formatter;

  final List<MaterialSearchResult<T>> results;
  final MaterialResultsFinder getResults;
  final MaterialSearchFilter<T> filter;
  final MaterialSearchSort<T> sort;
  final ValueChanged<T> onSelect;

  MaterialSearchInput({
    Key key,
    this.onSaved,
    this.validator,
    this.autovalidate,
    this.placeholder,
    this.formatter,
    this.results,
    this.getResults,
    this.filter,
    this.sort,
    this.onSelect,
  });

  @override
  _MaterialSearchInputState<T> createState() => _MaterialSearchInputState();
}

class _MaterialSearchInputState<T> extends State<MaterialSearchInput<T>> {
  // 父页面需要控制子页的需求。这时候就需要用到GlobalKey了
  GlobalKey<FormFieldState<T>> _formFieldKey =
      new GlobalKey<FormFieldState<T>>();

  _buildMaterialSearchPage(BuildContext context) {
    return new _MaterialSearchPageRoute<T>(
        settings:
            new RouteSettings(name: 'material_search', isInitialRoute: false),
        builder: (BuildContext context) {
          return new Material(
            child: new MaterialSearch(
              placeholder: widget.placeholder,
              results: widget.results,
              getResults: widget.getResults,
              filter: widget.filter,
              sort: widget.sort,
              onSelect: (dynamic value) => Navigator.of(context).pop(value),
            ),
          );
        });
  }

  _showMaterialSearch(BuildContext context) {
    Navigator.of(context)
        .push(_buildMaterialSearchPage(context))
        .then((dynamic value) {
      if (value != null) {
        _formFieldKey.currentState.didChange(value);
        widget.onSelect(value);
      }
    });
  }

  bool get autovalidate {
    return widget.autovalidate ??
        Form.of(context)?.widget?.autovalidate ??
        false;
  }

  bool _isEmpty(field) => field.value == null;

  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.subhead;

    return new InkWell(
      onTap: () => _showMaterialSearch(context),
      child: new FormField(
        key: _formFieldKey,
        validator: widget.validator,
        onSaved: widget.onSaved,
        autovalidate: autovalidate,
        builder: (FormFieldState<T> field) {
          return new InputDecorator(
            isEmpty: _isEmpty(field),
            decoration: new InputDecoration(
              labelText: widget.placeholder,
              border: InputBorder.none,
              errorText: field.errorText,
            ),
            child: _isEmpty(field)
                ? null
                : new Text(
                    widget.formatter != null
                        ? widget.formatter(field.value)
                        : field.value.toString(),
                    style: valueStyle),
          );
        },
      ),
    );
  }
}

//搜索框
class SearchInput extends StatelessWidget {
  final getResults;
  final ValueChanged<String> onSubmitted;

  final VoidCallback onSubmitPressed;

  SearchInput(this.getResults, this.onSubmitted, this.onSubmitPressed);

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 40.0,
      //背景装饰
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(4.0)),
      child: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(right: 10.0, top: 3.0, left: 10.0),
            child: new Icon(
              Icons.search,
              size: 24.0,
              color: Theme.of(context).accentColor,
            ),
          ),
          new Expanded(
            child: new MaterialSearchInput(
              placeholder: '搜索 flutter 组件',
              getResults: getResults,
            ),
          )
        ],
      ),
    );
  }
}


class History extends StatefulWidget {
  const History(): super();

  @override
  _History createState() => _History();
}

class _History extends State<History> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text('这是一个即将完善的历史记录的面板'),
    );
  }

}