import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/util/widget_util.dart';

class AccountAvatar extends StatelessWidget {
  final double size;
  final bool whitePadding;
  final String avatarUrl;
  final GestureTapCallback onTap;
  final bool cache;
  final Gender gender;

  const AccountAvatar(
      {Key key,
      this.avatarUrl,
      this.size = SizeConstant.TWEET_PROFILE_SIZE,
      this.onTap,
      this.cache = false,
      this.gender = Gender.UNKNOWN,
      this.whitePadding = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double genderFloatSize = (size / 3.5);
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
            border: whitePadding ? Border.all(width: 2, color: Colors.white) : null,
            borderRadius: BorderRadius.all((Radius.circular(50))),
          ),
          width: size,
          height: size,
          child: GestureDetector(
            onTap: onTap,
            child: ClipOval(
                child: !cache
                    ? FadeInImage.assetNetwork(
                        image: avatarUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: PathConstant.AVATAR_HOLDER,
                      )
                    : CachedNetworkImage(
                        imageUrl: avatarUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => LoadAssetImage(
                              PathConstant.IMAGE_FAILED,
                              width: SizeConstant.TWEET_PROFILE_SIZE,
                              height: SizeConstant.TWEET_PROFILE_SIZE,
                              fit: BoxFit.cover,
                            ))),
          )),
      (Gender.MALE == gender || Gender.FEMALE == gender)
          ? Positioned(
              bottom: 0,
              right: 0,
              child: gender == Gender.MALE
                  ? Container(
                      width: genderFloatSize,
                      height: genderFloatSize,
                      child: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: LoadAssetSvg(
                          'male',
                          width: genderFloatSize,
                          height: genderFloatSize,
                          color: Colors.white,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(
                      width: genderFloatSize,
                      height: genderFloatSize,
                      child: CircleAvatar(
                        backgroundColor: Colors.pink[200],
                        child: LoadAssetSvg(
                          'female',
                          width: genderFloatSize,
                          height: genderFloatSize,
                          color: Colors.white,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ))
          : Gaps.empty
    ]);
  }
}
