import 'dart:convert';

class OssConstant {
//验证文本域
  static String policyText =
      '{"expiration": "2025-01-01T12:00:00.000Z","conditions": [["content-length-range", 0, 1048576000]]}';

//进行utf8编码
  static List<int> policyTextUtf8 = utf8.encode(policyText);

//进行base64编码
  static String policyBase64 = base64.encode(policyTextUtf8);

//再次进行utf8编码
  static List<int> policy = utf8.encode(policyBase64);

  static const String ACCESS_KEY_ID = "LTAI4FukqK1vSNmmDv18VGXw";

  static const String ACCESS_KEY_SECRET = "iiUEipG0HKLTDYbdFoRAJPedn4XNu5";

  static const String POST_URL =
      "http://iutr-media.oss-cn-hangzhou.aliyuncs.com";

  static const String THUMBNAIL_SUFFIX = "?x-oss-process=style/image_thumbnail";
  static const String PREVIEW_SUFFIX = "?x-oss-process=style/image_preview";
}
