import 'package:flutter/material.dart';
import 'package:iap_app/global/shared_data.dart';
import 'package:iap_app/index/index.dart';
import 'package:provider/provider.dart';

import 'model/tweet.dart';

void main() {
  var tweetBloc = TweetBloc();

  runApp(
    Provider<List<BaseTweet>>.value(
      child: ChangeNotifierProvider.value(
        value: tweetBloc,
        child: Iap(),
      ),
    ),
  );
  // runApp(MultiProvider(providers: [
  //   Provider<TweetBloc>.value(value: tweetBloc),
  // ], child: Iap()));
}

class Iap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iap',
      home: Index(),
    );
  }
}
