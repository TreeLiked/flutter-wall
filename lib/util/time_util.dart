import 'package:flustars/flustars.dart';

class TimeUtil {
  static String getShortTime(DateTime dt) {
    dt = dt.subtract(Duration(hours: 5));
    int nowMs = DateTime.now().millisecondsSinceEpoch;
    int tarMs = dt.millisecondsSinceEpoch;
    // 相差的分钟
    int diffMin = (nowMs - tarMs) / 1000 ~/ 60;

    if (diffMin < 5) {
      return "刚刚";
    } else if (diffMin < 60) {
      return "$diffMin分钟前";
    } else {
      // 大于一小时
      int diffHour = diffMin ~/ 60;
      int leftMin = diffMin % 60;
      diffHour = leftMin > 30 ? diffHour + 1 : diffHour;

      if (DateUtil.isToday(dt.millisecondsSinceEpoch)) {
        if (diffHour < 12) {
          return "$diffHour小时前";
        }
        // 同一天显示上午下午
        return timeInDay(dt.hour) + "${dt.hour}:${dt.minute}";
      } else {
        if (DateUtil.isYesterdayByMillis(tarMs, nowMs)) {
          // 如果小于24小时，显示昨天
          return "昨天 " + timeInDay(dt.hour) + dt.hour.toString() + "时";
        } else {
          if (dt.year == DateTime.now().year) {
            // 同一年
            return MMDD(dt) + " ${dt.hour}:${dt.minute}";
          } else {
            return DateUtil.formatDate(dt, format: DataFormats.zh_y_mo_d_h_m);
          }
        }
      }
    }
  }

  static String timeInDay(int hour) {
    if (hour < 6) {
      return "凌晨";
    } else if (hour < 12) {
      return "上午";
    } else if (hour < 21) {
      return "下午";
    } else {
      return "晚上";
    }
  }

  // MM月DD日
  static String MMDD(DateTime dt) {
    return DateUtil.formatDate(dt, format: DataFormats.zh_mo_d);
  }

  // HH时mm分
  static String HHmm(DateTime dt) {
    return DateUtil.formatDate(dt, format: DataFormats.zh_h_m);
  }
}
