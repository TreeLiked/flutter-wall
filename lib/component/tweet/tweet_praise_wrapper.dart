// import 'package:flutter/material.dart';
// import 'package:iap_app/component/tweet/item/tweet_reply_item_simple.dart';
// import 'package:iap_app/global/global_config.dart';
// import 'package:iap_app/model/tweet.dart';
// import 'package:iap_app/model/tweet_reply.dart';
// import 'package:iap_app/res/gaps.dart';
// import 'package:iap_app/util/collection.dart';
//
// class TweetReplyWrapperSimple extends StatelessWidget {
//   final BaseTweet tweet;
//
//   TweetReplyWrapperSimple(this.tweet);
//
//   @override
//   Widget build(BuildContext context) {
//     if (!tweet.enableReply) {
//       return Gaps.empty;
//     }
//     var dirReplies = tweet.dirReplies;
//     if (dirReplies == null || dirReplies.length == 0) {
//       return Gaps.empty;
//     }
//     int len = dirReplies.length;
//     int replyCount = 0;
//     int totalCount = 0;
//     List<Widget> trWs = new List();
//     for (int i = 0; i < len; i++) {
//       if (replyCount == GlobalConfig.MAX_DISPLAY_REPLY || totalCount == GlobalConfig.MAX_DISPLAY_REPLY_ALL) {
//         break;
//       }
//       TweetReply dirTr = dirReplies[i];
//       trWs.add(TweetReplyItemSimple(
//         tweetAccountId: tweet.account.id,
//         tweetAnonymous: tweet.anonymous,
//         reply: dirTr,
//         parentId: dirTr.id,
//         onTapAccount: () {},
//         onTapReply: () {},
//       ));
//       replyCount++;
//       totalCount++;
//       if (replyCount == GlobalConfig.MAX_DISPLAY_REPLY || totalCount == GlobalConfig.MAX_DISPLAY_REPLY_ALL) {
//         break;
//       }
//       if (!CollectionUtil.isListEmpty(dirTr.children)) {
//         dirTr.children.forEach((tr) {
//           totalCount++;
//           trWs.add(TweetReplyItemSimple(
//             tweetAccountId: tweet.account.id,
//             tweetAnonymous: tweet.anonymous,
//             reply: tr,
//             parentId: dirTr.id,
//             onTapAccount: () {},
//             onTapReply: () {},
//           ));
//         });
//       }
//     }
//     return Container(
//         child: ListView(
//             shrinkWrap: true,
//             physics: new NeverScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(0),
//             children: trWs));
//   }
// }
