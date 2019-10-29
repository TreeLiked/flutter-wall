import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/util/shared.dart';
import 'package:iap_app/util/string.dart';

class AccountUtil {
  static getNickFromAccount(Account account, bool anonymous) {
    if (anonymous) {
      return TextConstant.TWEET_ANONYMOUS_NICK;
    }
    if (account != null) {
      if (!StringUtil.isEmpty(account.nick)) {
        return account.nick;
      }
    }
    return '';
  }

  static Future<String> getStorageAccountId() async {
    return await SharedPreferenceUtil.readStringValue(
        SharedConstant.LOCAL_ACCOUNT_ID);
  }
}
