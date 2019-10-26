/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './route_handlers.dart';

class Routes {
  static String index = "/";
  static String home = "/home";
  static String hot = "/hot";
  static String create = "/home/create";
  static String filter = "/home/filter";

  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE HANDLER WAS NOT FOUND !!!");
    });
    router.define(index, handler: indexHander);
    router.define(home, handler: homeHandler);

    router.define(create, handler: createHandler);

    // router.define(hot,
    //     handler: demoRouteHandler, transitionType: TransitionType.inFromLeft);
    // router.define(create, handler: demoFunctionHandler);
    // router.define(filter, handler: deepLinkHandler);
  }
}
