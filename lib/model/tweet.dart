import 'package:iap_app/model/Account.dart';

class Tweet {
  String id;
  String unId;
  String body;
  String type;
  bool anonymous;
  Account account;
  bool enableReply;

  Tweet(this.body, this.type, this.anonymous);
}

enum Color { CONFESSION }
