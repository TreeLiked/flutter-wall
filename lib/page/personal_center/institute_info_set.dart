import 'dart:async';

import 'package:flustars/flustars.dart' as prefix0;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/univer.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/school/institute.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/result_code.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/page/login/reg_temp.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/login_router.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:provider/provider.dart';

class InstituteInfoSetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InstituteInfoSetPageState();
  }
}

class _InstituteInfoSetPageState extends State<InstituteInfoSetPage> {
  TextEditingController _controller;
  Future _queryUnTask;

  Duration durationTime = Duration(seconds: 1);

  // 防抖函数
  Timer timer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _queryUnTask = queryInstitutes();
  }

  Future<Result<List<Institute>>> queryInstitutes() async {
    return UniversityApi.queryUniInstitutes();
  }

  void filterInstitute() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          centerTitle: '选择学院',
        ),
        body: Column(
          children: <Widget>[
            Gaps.vGap16,
            Container(
//                    height: ScreenUtil().setHeight(80),
              padding: const EdgeInsets.symmetric(vertical: 1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: ThemeUtils.isDark(context) ? Color(0xff363636) : Color(0xfff2f2f2),
              ),
              margin: EdgeInsets.symmetric(horizontal: Dimens.gap_dp5),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) async => filterInstitute(),
                onChanged: (val) async {
                  setState(() {
                    timer?.cancel();
                    timer = new Timer(durationTime, () => filterInstitute());
                  });
                },
                style: TextStyles.textBold14,
                decoration: InputDecoration(
                    hintText: '输入学院名称以搜索',
                    hintStyle: TextStyles.textGray14,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    suffixIcon: GestureDetector(
                      child: Icon(
                        Icons.clear,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _controller.clear();
                        filterInstitute();
                      },
                    ),
                    border: InputBorder.none),
                maxLines: 1,
              ),
            ),
            Expanded(
                child: Container(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.all(0),
                    child: FutureBuilder<Result<List<Institute>>>(
                        builder: (context, AsyncSnapshot<Result<List<Institute>>> async) {
                          if (async.connectionState == ConnectionState.active ||
                              async.connectionState == ConnectionState.waiting) {
                            return Container(
                              margin: EdgeInsets.only(top: 37),
                              child: new SpinKitChasingDots(
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
                              Result<List<Institute>> r = async.data;
                              if (!r.isSuccess) {
                                return Center(
                                  child: Text(r.message),
                                );
                              }
                              List<Institute> list = async.data.data;

                              if (list == null || list.length == 0) {
                                return Padding(
                                    padding: const EdgeInsets.only(top: 37),
                                    child: Text('没有满足条件的数据', style: TextStyles.textGray14));
                              }
                              String filterText = _controller.text;
                              bool filter = filterText.isNotEmpty;
                              List<Institute> display =
                                  filter ? list.where((f) => f.name.contains(filterText)).toList() : list;
                              return ListView.builder(
                                  itemCount: display.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: () => NavigatorUtils.goBackWithParams(context, display[index]),
                                      title: Text(display[index].name),
                                    );
                                  });
                            }
                          }
                          return Gaps.empty;
                        },
                        future: _queryUnTask)))
          ],
        ));
  }
}
