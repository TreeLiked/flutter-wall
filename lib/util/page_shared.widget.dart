import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PageSharedWidget {
  static final ScrollController _homepageScrollController = ScrollController();

  static final RefreshController _tabIndexRefreshController = RefreshController(initialRefresh: false);


  static ScrollController get homepageScrollController => _homepageScrollController;

  static RefreshController get tabIndexRefreshController => _tabIndexRefreshController;
}
