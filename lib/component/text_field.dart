import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:rxdart/rxdart.dart';

/// 登录模块的输入框封装
class MyTextField extends StatefulWidget {
  const MyTextField(
      {Key key,
      @required this.controller,
      this.maxLength: 16,
      this.autoFocus: false,
      this.keyboardType: TextInputType.text,
      this.hintText: "",
      this.focusNode,
      this.isInputPwd: false,
      this.getVCode,
      this.config,
      this.onChange,
      this.keyName})
      : super(key: key);

  final TextEditingController controller;
  final int maxLength;
  final bool autoFocus;
  final TextInputType keyboardType;
  final String hintText;
  final FocusNode focusNode;
  final bool isInputPwd;
  final Future<bool> Function() getVCode;
  final KeyboardActionsConfig config;
  final onChange;

  /// 用于集成测试寻找widget
  final String keyName;

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isShowPwd = false;
  bool _isShowDelete;
  bool _isClick = true;

  /// 倒计时秒数
  final int second = 90;

  /// 当前秒数
  int s;
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    /// 获取初始化值
    _isShowDelete = widget.controller.text.isEmpty;

    /// 监听输入改变
    widget.controller.addListener(() {
      setState(() {
        _isShowDelete = widget.controller.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.controller?.removeListener(() {});
    widget.controller?.dispose();
    super.dispose();
  }

  Future _getVCode() async {
    bool isSuccess = await widget.getVCode();
    if (isSuccess != null && isSuccess) {
      setState(() {
        s = second;
        _isClick = false;
      });
      _subscription = Observable.periodic(Duration(seconds: 1), (i) => i)
          .take(second)
          .listen((i) {
        setState(() {
          s = second - i - 1;
          _isClick = s < 1;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config != null && defaultTargetPlatform == TargetPlatform.iOS) {
      // 因Android平台输入法兼容问题，所以只配置IOS平台
      FormKeyboardActions.setKeyboardActions(context, widget.config);
    }
    ThemeData themeData = Theme.of(context);
    bool isDark = themeData.brightness == Brightness.dark;
    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        TextField(
          focusNode: widget.focusNode,
          maxLength: widget.maxLength,
          obscureText: widget.isInputPwd ? !_isShowPwd : false,
          autofocus: widget.autoFocus,
          controller: widget.controller,
          textInputAction: TextInputAction.done,
          keyboardType: widget.keyboardType,
          // 数字、手机号限制格式为0到9(白名单)， 密码限制不包含汉字（黑名单）
          inputFormatters: (widget.keyboardType == TextInputType.number ||
                  widget.keyboardType == TextInputType.phone)
              ? [WhitelistingTextInputFormatter(RegExp("[0-9]"))]
              : (widget.keyboardType != TextInputType.text
                  ? [BlacklistingTextInputFormatter(RegExp("[\u4e00-\u9fa5]"))]
                  : null),
          onChanged: (val) => widget.onChange(val),
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
              hintText: widget.hintText,
              counterText: "",
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: themeData.primaryColor, width: 0.8)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).dividerTheme.color,
                      width: 0.8))),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _isShowDelete
                ? Gaps.empty
                : GestureDetector(
                    child: LoadAssetImage(
                      "login/qyg_shop_icon_delete",
                      key: Key('${widget.keyName}_delete'),
                      width: 18.0,
                      height: 18.0,
                    ),
                    onTap: () {
                      widget.controller.text = "";
                    },
                  ),
            !widget.isInputPwd ? Gaps.empty : Gaps.hGap15,
            !widget.isInputPwd
                ? Gaps.empty
                : GestureDetector(
                    child: LoadAssetImage(
                      _isShowPwd
                          ? "login/qyg_shop_icon_display"
                          : "login/qyg_shop_icon_hide",
                      key: Key('${widget.keyName}_showPwd'),
                      width: 18.0,
                      height: 18.0,
                    ),
                    onTap: () {
                      setState(() {
                        _isShowPwd = !_isShowPwd;
                      });
                    },
                  ),
            widget.getVCode == null ? Gaps.empty : Gaps.hGap15,
            widget.getVCode == null
                ? Gaps.empty
                : Theme(
                    data: Theme.of(context).copyWith(
                      buttonTheme: ButtonThemeData(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        height: 26.0,
                        minWidth: 76.0,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    child: FlatButton(
                      onPressed: _isClick ? _getVCode : null,
                      textColor: themeData.primaryColor,
                      color: Colors.transparent,
                      disabledTextColor:
                          isDark ? Colours.dark_text : Colors.white,
                      disabledColor:
                          isDark ? Colours.dark_text_gray : Colours.text_gray_c,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.0),
                          side: BorderSide(
                            color: _isClick
                                ? themeData.primaryColor
                                : Colors.transparent,
                            width: 0.8,
                          )),
                      child: Text(
                        _isClick ? "获取验证码" : "（$s s）",
                        style: TextStyle(fontSize: Dimens.font_sp12),
                      ),
                    ),
                  )
          ],
        )
      ],
    );
  }
}
