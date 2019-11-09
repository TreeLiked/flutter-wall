import 'package:flustars/flustars.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/util/string.dart';

// 选择组织页面
class OrgChoosePage extends StatefulWidget {
  final String _title;
  String _hintText;
  OrgChoosePage(this._title, {String hintText}) {
    if (StringUtil.isEmpty(hintText)) {
      this._hintText = "在这里搜索";
    } else {
      this._hintText = hintText;
    }
  }
  @override
  State<StatefulWidget> createState() {
    return _OrgChoosePageState();
  }
}

class _OrgChoosePageState extends State<OrgChoosePage> {
  List<String> _orgList = [
    "南京大学",
    "东南大学",
    "南京农业大学",
    "河海大学",
    "中国药科大学",
    "南京航空航天大学",
    "南京理工大学",
    "南京森林警察学院",
    "金陵协和神学院",
    "解放军理工大学",
    "陆军指挥学院",
    "海军指挥学院",
    "炮兵学院南京分院",
    "解放军国际关系学院",
    "南京政治学院",
    "南京师范大学",
    "南京工业大学",
    "南京医科大学",
    "南京邮电大学",
    "南京林业大学",
    "南京财经大学",
    "南京中医药大学",
    "南京信息工程大学",
    "南京审计大学",
    "南京艺术学院",
    "南京体育学院",
    "江苏警官学院",
    "南京工程学院",
    "南京晓庄学院",
    "金陵科技学院",
    "三江学院",
    "江苏经贸职业技术学院",
    "江苏联合职业技术学院",
    "江苏城市职业学院",
    "江苏海事职业技术学院",
    "南京高等职业技术学校",
    "南京铁道职业技术学院",
    "南京特殊教育职业技术学院",
    "南京视觉艺术职业技术学院",
    "南京机电职业技术学院",
    "南京交通职业技术学院",
    "南京信息职业技术学院",
    "南京化工职业技术学院",
    "南京工业职业技术学院",
    "钟山职业技术学院",
    "正德职业技术学院",
    "培尔职业技术学院",
    "应天职业技术学院",
    "金肯职业技术学院",
    "南京大学金陵学院",
    "东南大学成贤学院",
    "南京理工大学紫金学院",
    "南京航空航天大学金城学院",
    "南京师范大学中北学院",
    "南京工业大学浦江学院",
    "南京医科大学康达学院",
    "南京中医药大学翰林学院",
    "南京信息工程大学滨江学院",
    "南京邮电大学通达学院",
    "南京财经大学红山学院",
    "南京审计学院金审学院",
    "南京工程学院康尼学院",
    "中国传媒大学南广学院",
    "江苏教育学院",
    "江苏省广播电视大学",
    "江苏省省级机关管理干部学院",
    "江苏建康职业学院",
    "南京城市职业学院",
    "南京人口管理干部学院",
    "南京电子工业职工大学",
    "南京联合职工大学",
    "空军第一职工大学"
  ];

  List<String> filterList;

  TextEditingController _controller;

  String _chooseOrgName = "";
  int _chooseOrgId = -1;

  @override
  void initState() {
    super.initState();
    // List.copyRange(filterList, 0, _orgList);
    _controller = TextEditingController();
    print(filterList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          centerTitle: widget._title,
          actionName: "完成",
          onPressed: () {
            NavigatorUtils.goBack(context);
          },
        ),
        body: Column(
          children: <Widget>[
            Gaps.vGap16,
            Container(
              height: ScreenUtil().setHeight(80),
              margin: EdgeInsets.symmetric(horizontal: Dimens.gap_dp5),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    hintText: widget._hintText,
                    hintStyle: TextStyles.textGray12,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    suffixIcon: GestureDetector(
                      child: Icon(
                        Icons.clear,
                        color: Colors.grey,
                      ),
                      onTap: () => _controller.clear(),
                    ),
                    filled: true,
                    fillColor: Color(0xfff5f6f7),

                    // enabledBorder: InputBorder(),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 0.0, style: BorderStyle.none),
                      borderRadius: BorderRadius.circular(15),
                    )),
                maxLines: 1,
              ),
            )
            // SingleChildScrollView(

            // )
          ],
        ));
  }

  _renderList() {}
}
