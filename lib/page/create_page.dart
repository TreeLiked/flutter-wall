import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/global/global_config.dart';

class CreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreatePageState();
  }
}

class _CreatePageState extends State<CreatePage> {
  Widget contentArea() {
    return Row(
      children: <Widget>[
        Text('data'),
        TextField(
          decoration: new InputDecoration(
            hintText: 'Type something',
          ),
        )
      ],
    );
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    bool _enbaleReply;
    // final ValueNotifier<String> _reply_text = ValueNotifier<String>("打开");
    String _replyText = "打开";

    bool _anonymous = false;

    return MaterialApp(
      theme: GlobalConfig.td,
      home: new Scaffold(
          appBar: new AppBar(
            title: Text('发布内容'),
          ),
          backgroundColor: Colors.white,
          body: new SingleChildScrollView(
            child: new Container(
              padding: EdgeInsets.all(10),
              child: new Column(
                children: <Widget>[
                  new Container(
                      child: PreferredSize(
                    preferredSize: Size.fromHeight(300),
                    child: TextField(
                      cursorColor: Colors.blue,
                      maxLengthEnforced: true,
                      maxLength: 256,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: TextStyle(fontSize: 17),
                      decoration: new InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(5),
                          counterText: 'dasds'),
                      onChanged: (val) {},
                    ),
                  )),
                  Divider(
                    height: 1.0,
                    indent: 0.0,
                    color: Color(0xffF5F5F5),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.blur_on,
                                size: GlobalConfig.CREATE_ICON_SIZE,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  '内容类型',
                                  style: TextStyle(
                                      fontSize:
                                          GlobalConfig.CREATE_ICON_FONT_SIZE),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Icon(
                                      Icons.chevron_right,
                                      color: GlobalConfig.tweetTimeColor,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.grain,
                                size: GlobalConfig.CREATE_ICON_SIZE,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  '为我匿名',
                                  style: TextStyle(
                                      fontSize:
                                          GlobalConfig.CREATE_ICON_FONT_SIZE),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      '关闭',
                                      style: TextStyle(
                                          color: GlobalConfig
                                              .TEXT_DEFAULT_CLICKABLE_COLOR),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: GlobalConfig.tweetTimeColor,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.reply,
                                size: GlobalConfig.CREATE_ICON_SIZE,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  '开启评论',
                                  style: TextStyle(
                                      fontSize:
                                          GlobalConfig.CREATE_ICON_FONT_SIZE),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _replyText = "关闭";
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        _replyText,
                                        style: TextStyle(
                                            color: GlobalConfig
                                                .TEXT_DEFAULT_CLICKABLE_COLOR),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: GlobalConfig.tweetTimeColor,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
    );
    // return new MaterialApp(
    //     theme: GlobalConfig.td,
    //     home: Scaffold(
    //         appBar: AppBar(
    //           title: Text('发表内容'),
    //           backgroundColor: GlobalConfig.DEFAULT_BAR_BACK_COLOR,
    //         ),
    //         body: new SingleChildScrollView(
    //           child: new Container(
    //             child: new Row(
    //               children: <Widget>[
    //                 Text('data'),
    //                 contentArea(),
    //               ],
    //             ),
    //           ),
    //         )));
  }
}
