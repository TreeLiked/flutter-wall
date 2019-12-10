import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';

class TweetTypeSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TweetTypeSelectPage();
  }
}

class _TweetTypeSelectPage extends State<TweetTypeSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        centerTitle: '',
      ),
    );
  }
}
