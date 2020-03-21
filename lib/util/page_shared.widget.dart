import 'package:flutter/cupertino.dart';

class PageSharedWidget {
  static final ScrollController _homepageScrollController = ScrollController();

  static get homepageScrollController => _homepageScrollController;
}
