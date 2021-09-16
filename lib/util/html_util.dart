import 'dart:collection';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class HtmlUtils {
  static Document parseDocument(String html) {
    if (html != null && html.length > 0) {
      return parse(html);
    }
    return null;
  }

  static String getDocTitle(Document doc) {
    if (doc != null) {
      List<Element> titles = doc.getElementsByTagName("title");
      if (checkListNotEmpty(titles)) {
        Element title = titles[0];
        return title.text;
      }
    }
    return null;
  }

  static String getDocFaviconPath(Document doc) {
    if (doc != null) {
      List<Element> links = doc.getElementsByTagName("link");
      if (checkListNotEmpty(links)) {
        for (final Element ele in links) {
          LinkedHashMap<String, String> attrs = ele.attributes;
          if (checkMapNotEmpty(attrs)) {
            if (attrs.containsKey("rel") || attrs.containsKey("REL")) {
              String val = attrs["rel"] ?? attrs["REL"];
              if (checkStrNotEmpty(val) && (val.contains("icon") || val.contains("ICON"))) {
                if (attrs.containsKey("href")) {
                  val = attrs["href"];
                  if (checkStrNotEmpty(val)) {
                    val = val.trim();
                    if (val.startsWith("//")) {
                      val = "http:" + val;
                      return val;
                    } else {
                      if (val.startsWith("http")) {
                        return val;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return null;
  }

  static bool checkListNotEmpty(List l) {
    return l != null && l.length > 0;
  }

  static bool checkMapNotEmpty(Map m) {
    return m != null && m.length > 0;
  }

  static bool checkStrNotEmpty(String s) {
    return s != null && s.length > 0;
  }
}
