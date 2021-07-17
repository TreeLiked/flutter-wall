/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/page/account_profile/account_profile.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/page/home/create_page.dart';
import 'package:iap_app/page/home/home_page.dart';
import 'package:iap_app/page/index/index.dart';
import 'package:iap_app/page/input_text_page.dart';
import 'package:iap_app/page/notification/index.dart';
import 'package:iap_app/page/square/index.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/page/tweet_type_sel.dart';
import 'package:iap_app/util/fluro_convert_utils.dart';

var indexHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return Index();
});

var homeHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return HomePage();
});

var squareHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SquareIndexPage();
});

var tweetDetailHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TweetDetail(null);
});

var createHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String type = params['type'].first;
  return CreatePage(
      type: type,
      title: FluroConvertUtils.fluroCnParamsDecode(params['title'].first),
      hintText: FluroConvertUtils.fluroCnParamsDecode(params['hintText'].first));
});

var notificationHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return NotificationIndexPage();
});

var filterHander = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TweetTypeSelect();
});

var inputPageHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String title = params['title'] == null ? "" : FluroConvertUtils.fluroCnParamsDecode(params['title'].first);
  String hintText =
      params['hintText'] == null ? "" : FluroConvertUtils.fluroCnParamsDecode(params['hintText'].first);

  int limit =
      params['limit'] == null ? 16 : int.parse(FluroConvertUtils.fluroCnParamsDecode(params['limit'].first));

  bool showLimit =
      params['showLimit'] == null ? true : (params['limit'].first.toLowerCase() == "true" ? true : false);

  int keyboardType =
      params['kt'] == null ? 0 : int.parse(FluroConvertUtils.fluroCnParamsDecode(params['kt'].first));

  String url = params['url'] == null ? "" : FluroConvertUtils.fluroCnParamsDecode(params['url'].first);
  String key = params['key'] == null ? "" : FluroConvertUtils.fluroCnParamsDecode(params['key'].first);

  return InputTextPage(
    title: title,
    hintText: hintText,
    limit: limit,
    showLimit: showLimit,
    keyboardType: keyboardType,
    queryTaskUrl: url,
    queryTaskKey: key,
  );
});

var reportHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String type = params['type'].first;
  String refId = params['refId'].first;
  String title = params['title'].first;

  return ReportPage(type, refId, title);
});

var accountProfileHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String nick = params['nick'] == null ? "" : FluroConvertUtils.fluroCnParamsDecode(params['nick'].first);
  String accountId =
      params['accId'] == null ? "" : FluroConvertUtils.fluroCnParamsDecode(params['accId'].first);

  String avatarUrl =
      params['avatarUrl'] == null ? "" : FluroConvertUtils.fluroCnParamsDecode(params['avatarUrl'].first);

  return AccountProfile(accountId, nick, avatarUrl);
});
