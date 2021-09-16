import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/tweet_type.dart';
import 'package:iap_app/util/collection.dart';

class TweetTypesFilterProvider extends ChangeNotifier {
  List<String> _selTypeNames;
  bool _selAll = true;

  bool get selectAll => _selAll;
  List<String> get selTypeNames => _selTypeNames;

  void refresh() {
    notifyListeners();
  }

  void updateTypeNames() {
    List<String> types =
        SpUtil.getStringList(SharedConstant.LOCAL_FILTER_TYPES, defValue: []);
    if (CollectionUtil.isListEmpty(types)) {
      _selAll = true;
      _selTypeNames = List()
        ..addAll(TweetTypeUtil.getFilterableTweetTypeMap()
            .keys
            .map((nameKey) => nameKey.toString())
            .toList());
    } else {
      _selAll = false;
      _selTypeNames = new List()..addAll(types);
    }
    refresh();
  }

  // void updateTypeNamesWith(List<String> names) async{

  //   if (CollectionUtil.isListEmpty(types)) {
  //     _selAll = true;
  //     _selTypeNames = List()
  //       ..addAll(TweetTypeUtil.getAllTweetTypeMap()
  //           .keys
  //           .map((nameKey) => nameKey.toString())
  //           .toList());
  //   } else {
  //     _selAll = false;
  //     _selTypeNames = new List()..addAll(types);
  //   }
  //   refresh();
  // }
}
