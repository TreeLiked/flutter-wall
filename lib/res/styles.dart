import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iap_app/global/text_constant.dart';

import 'colors.dart';
import 'dimens.dart';

class TextStyles {
  static const TextStyle textSize12 = const  TextStyle(
    fontSize: Dimens.font_sp12,
      fontFamily: TextConstant.PING_FANG_FONT

  );
  static const TextStyle textSize14 = const TextStyle(
    fontSize: Dimens.font_sp14,
    fontFamily: TextConstant.PING_FANG_FONT
  );

  static const TextStyle textSize10 = const TextStyle(
      fontSize: Dimens.font_sp10, color: Colors.white, fontFamily: TextConstant.PING_FANG_FONT);
  static const TextStyle textSize16 =
      const TextStyle(fontSize: Dimens.font_sp16, fontFamily: TextConstant.PING_FANG_FONT);
  static const TextStyle textBold14 = const TextStyle(
      fontSize: Dimens.font_sp14, fontWeight: FontWeight.bold, fontFamily: TextConstant.PING_FANG_FONT);
  static const TextStyle textBold16 = const TextStyle(
      fontSize: Dimens.font_sp16, fontWeight: FontWeight.bold, fontFamily: TextConstant.PING_FANG_FONT);
  static const TextStyle textBold18 = const TextStyle(
      fontSize: Dimens.font_sp18, fontWeight: FontWeight.bold, fontFamily: TextConstant.PING_FANG_FONT);
  static const TextStyle textBold24 =
      const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, fontFamily: TextConstant.PING_FANG_FONT);
  static const TextStyle textBold26 =
      const TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, fontFamily: TextConstant.PING_FANG_FONT);

  static const TextStyle textGray14 = const TextStyle(
    fontSize: Dimens.font_sp14,
    color: Colours.text_gray,
    fontFamily: TextConstant.PING_FANG_FONT,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle textGray16 = const TextStyle(
    fontSize: Dimens.font_sp16,
    fontFamily: TextConstant.PING_FANG_FONT,
    color: Colours.text_gray,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle textDarkGray14 = const TextStyle(
    fontSize: Dimens.font_sp14,
    fontFamily: TextConstant.PING_FANG_FONT,
    color: Colours.dark_text_gray,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textWhite14 = const TextStyle(
    fontSize: Dimens.font_sp14,
    color: Colors.white,
    fontFamily: TextConstant.PING_FANG_FONT,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textClickable = const TextStyle(
      fontSize: Dimens.font_sp14, color: Color(0xff02376a), fontFamily: TextConstant.PING_FANG_FONT);

  static const commonTextStyle =
      const TextStyle(fontSize: 16, color: Colors.black87, fontFamily: TextConstant.PING_FANG_FONT);

  static const TextStyle text = const TextStyle(
      fontFamily: TextConstant.PING_FANG_FONT,
      fontSize: Dimens.font_sp14,
      color: Colours.text,
      // https://github.com/flutter/flutter/issues/40248
      textBaseline: TextBaseline.alphabetic);
  static const TextStyle textDark = const TextStyle(
      fontFamily: TextConstant.PING_FANG_FONT,
      fontSize: Dimens.font_sp14,
      color: Colours.dark_text,
      textBaseline: TextBaseline.alphabetic);

  static const TextStyle textGray12 = const TextStyle(
      fontSize: Dimens.font_sp12,
      color: Colours.text_gray,
      fontWeight: FontWeight.w400,
      fontFamily: TextConstant.PING_FANG_FONT);
  static const TextStyle textDarkGray12 = const TextStyle(
      fontSize: Dimens.font_sp12,
      color: Colours.dark_text_gray,
      fontWeight: FontWeight.w400,
      fontFamily: TextConstant.PING_FANG_FONT);

  static const TextStyle textHint14 = const TextStyle(
      fontSize: Dimens.font_sp14,
      color: Colours.dark_unselected_item_color,
      fontFamily: TextConstant.PING_FANG_FONT);

  static const TextStyle textLightHint14 = const TextStyle(
      fontSize: Dimens.font_sp14, color: Color(0xff696969), fontFamily: TextConstant.PING_FANG_FONT);
}
