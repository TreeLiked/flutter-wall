import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';

class AccountProfilePage extends StatefulWidget {
  final String nick;
  final String accountId;

  AccountProfilePage(this.accountId, this.nick);

  @override
  State<StatefulWidget> createState() {
    return _AccountProfilePageState();
  }
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        centerTitle: widget.nick,
      ),
    );
  }
}
