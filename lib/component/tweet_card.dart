import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:iap_app/global/global_config.dart';
import 'package:iap_app/model/tweet.dart';

class TweetCard extends StatefulWidget {
  final BaseTweet _tweet;
  TweetCard(this._tweet);

  @override
  State<StatefulWidget> createState() {
    return _TweetCardState(_tweet);
  }
}

class _TweetCardState extends State<TweetCard> {
  BaseTweet _tweet;

  _TweetCardState(this._tweet);

  Widget cardContainer() {
    Widget wd = new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(2, 0, 10, 0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://tva1.sinaimg.cn/large/006y8mN6gy1g7dtpkfm07j30fj0f9dgs.jpg',
                  width: 44,
                  height: 44,
                ),
              )
            ],
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '愿为东南风',
                    style: TextStyle(
                        fontSize: GlobalConfig.TWEET_FONT_SIZE,
                        fontWeight: FontWeight.bold,
                        color: GlobalConfig.tweetNickColor),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text('8分钟前',
                            style: TextStyle(
                              fontSize: 14,
                              color: GlobalConfig.tweetTimeColor,
                            ))
                      ],
                    ),
                  )
                ],
              ),
              Container(
                child: Wrap(
                  spacing: 2, //主轴上子控件的间距
                  runSpacing: 5, //交叉轴上子控件之间的间距
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '（1）不当最佳辩手，不纠结自己对和别人错，放下自以为和常识，学会聆听；\n\n（2）不放弃，不抱怨，不怕受委屈；\n\n（3）搁置争议、相互信任、快速执行、勇于担任责任',
                            softWrap: true,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 10,
                            style: TextStyle(
                                fontSize: GlobalConfig.TWEET_FONT_SIZE,
                                color: GlobalConfig.tweetBodyColor),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Image.network(
                      'https://tva1.sinaimg.cn/large/006y8mN6gy1g7d7p910v1j30u00u0dhh.jpg',
                      width: 100,
                      height: 100,
                    ),
                    Image.network(
                      'https://tva1.sinaimg.cn/large/006y8mN6gy1g7d7p910v1j30u00u0dhh.jpg',
                      width: 100,
                      height: 100,
                    ),
                    Image.network(
                      'https://tva1.sinaimg.cn/large/006y8mN6gy1g7d7p910v1j30u00u0dhh.jpg',
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),
              ),
              Container(
                padding: prefix0.EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '吐槽',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: GlobalConfig.tweetTypeColor),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Icon(Icons.thumb_up),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 100.0,
          indent: 0.0,
          color: Colors.red,
        ),
      ],
    );
    return wd;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: cardContainer(),
      padding: EdgeInsets.fromLTRB(8, 20, 8, 10),
      color: Colors.white,
    );
  }
}
