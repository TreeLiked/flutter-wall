import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/global/size_constant.dart';

class AccountAvatar extends StatelessWidget {
  final double size;
  final bool whitePadding;
  final String avatarUrl;
  final GestureTapCallback onTap;

  AccountAvatar(
      {Key key,
      this.avatarUrl,
      this.size = SizeConstant.TWEET_PROFILE_SIZE,
      this.onTap,
      this.whitePadding = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border:
              whitePadding ? Border.all(width: 2, color: Colors.white) : null,
          borderRadius: BorderRadius.all((Radius.circular(50))),
        ),
        width: size,
        height: size,
        child: GestureDetector(
          onTap: onTap,
          child: ClipOval(
              child: CachedNetworkImage(
            imageUrl: avatarUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          )),
        )
        // child: GestureDetector(
        //   onTap: onTap,
        //   child: ClipOval(
        //       child: Image.network(
        //     avatarUrl,
        //     width: double.infinity,
        //     height: double.infinity,
        //     fit: BoxFit.cover,
        //   )),
        // )
        );
  }
}
