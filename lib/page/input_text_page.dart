import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/api/common.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';

class InputTextPage extends StatefulWidget {
  InputTextPage({
    Key key,
    @required this.title,
    this.content,
    this.hintText,
    this.limit = 16,
    this.showLimit = true,
    this.keyboardType = 0,
    this.queryTaskUrl,
    this.queryTaskKey,
  }) : super(key: key);

  final String title;
  final String content;
  final String hintText;
  final int limit;
  final bool showLimit;
  final int keyboardType;
  final String queryTaskUrl;
  final String queryTaskKey;

  @override
  _InputTextPageState createState() => _InputTextPageState();
}

class _InputTextPageState extends State<InputTextPage> {
  TextEditingController _controller = TextEditingController();

  Future _queryTask;
  bool query = false;

  Duration durationTime = Duration(seconds: 1);

  // 防抖函数
  Timer timer;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.content;

    query = !StringUtil.isEmpty(widget.queryTaskUrl) && !StringUtil.isEmpty(widget.queryTaskKey);
    if (query) {
      _queryTask = queryData();
    }
  }

  Future<Result<List<String>>> queryData() async {
    String url = widget.queryTaskUrl + "?${widget.queryTaskKey}=" + _controller.text.trim();
    return CommonApi.blueQueryDataList(url);
  }

  void filterData() {
    setState(() {
      _queryTask = queryData();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return Scaffold(
        appBar: MyAppBar(
          title: widget.title,
          actionName: "完成",
          onPressed: () {
            NavigatorUtils.goBackWithParams(context, _controller.text);
          },
        ),
        body: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0),
              padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0),
              decoration: BoxDecoration(
                  color: ThemeUtils.isDark(context)
                      ? ColorConstant.DEFAULT_BAR_BACK_COLOR_DARK
                      : ColorConstant.DEFAULT_BAR_BACK_COLOR,
                  borderRadius: BorderRadius.circular(8.0)),
              child: TextField(
                  maxLength: widget.limit,
                  maxLengthEnforced: widget.showLimit,
                  maxLines: 5,
                  autofocus: true,
                  controller: _controller,
                  keyboardType: widget.keyboardType == 0 ? TextInputType.text : TextInputType.phone,
                  keyboardAppearance: Theme.of(context).brightness,

                  //style: TextStyles.textDark14,

                  style: TextStyle(height: 1.6, fontSize: Dimens.font_sp15, letterSpacing: 1.3),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    hintMaxLines: 3,
                    hintStyle: TextStyle(height: 1.6, fontSize: Dimens.font_sp15, letterSpacing: 1.3),
                  ),
                  onSubmitted: (_) async {
                    if (query) {
                      filterData();
                    }
                  },
                  onChanged: (val) async {
                    if (query) {
                      setState(() {
                        timer?.cancel();
                        timer = new Timer(durationTime, () => filterData());
                      });
                    }
                  }),
            ),
            query
                ? Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: FutureBuilder<Result<List<String>>>(
                            builder: (context, AsyncSnapshot<Result<List<String>>> async) {
                              if (async.connectionState == ConnectionState.active ||
                                  async.connectionState == ConnectionState.waiting) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: SpinKitThreeBounce(
                                    color: Colors.lightGreen,
                                    size: 18,
                                  ),
                                );
                              }
                              if (async.connectionState == ConnectionState.done) {
                                if (async.hasError) {
                                  return Center(
                                    child: Text(TextConstant.TEXT_SERVICE_ERROR),
                                  );
                                } else if (async.hasData) {
                                  Result<List<String>> r = async.data;
                                  if (!r.isSuccess) {
                                    return Center(
                                      child: Text(r.message),
                                    );
                                  }
                                  List<String> list = async.data.data;

                                  if (list == null || list.length == 0) {
                                    return Padding(
                                        padding: const EdgeInsets.only(top: 37),
                                        child: Text('没有满足条件的数据', style: TextStyles.textGray14));
                                  }
                                  String filterText = _controller.text;
                                  bool filter = filterText.isNotEmpty;
                                  List<String> display = filter
                                      ? list.where((name) => name.contains(filterText)).toList()
                                      : list;
                                  return ListView.builder(
                                      itemCount: display.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        String filterText = _controller.text.trim();
                                        String value = display[index];
                                        int startIndex = value.indexOf(filterText);
                                        return ListTile(
                                          leading: Text("${index + 1}"),
                                          dense: true,
                                          onTap: () {
                                            NavigatorUtils.goBackWithParams(context, value);
                                          },
                                          title: RichText(
                                            text: TextSpan(children: [
                                              TextSpan(
                                                  text: value.substring(0, startIndex),
                                                  style: TextStyle(
                                                      color: isDark ? Colors.white70 : Colors.black87)),
                                              TextSpan(
                                                  text: value.substring(
                                                      startIndex, startIndex + filterText.length),
                                                  style: const TextStyle(color: Colors.lightBlue)),
                                              TextSpan(
                                                  text: value.substring(
                                                      startIndex + filterText.length, value.length),
                                                  style: TextStyle(
                                                      color: isDark ? Colors.white70 : Colors.black87)),
                                            ]),
                                          ),
                                        );
                                      });
                                }
                              }
                              return Gaps.empty;
                            },
                            future: _queryTask)),
                  )
                : Gaps.empty
          ],
        ));
  }
}
