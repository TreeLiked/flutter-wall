import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iap_app/routes/fluro_navigator.dart';

class ImageOriginPage extends StatelessWidget {
  final String url;
  final ByteData imageData;

  bool network = true;

  ImageOriginPage(this.url, this.imageData) {
    if (url == null) {
      network = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Hero(
            tag: 'image',
            child: GestureDetector(
              child: network
                  ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover)
                  : Image.memory(
                      imageData.buffer.asUint8List(),
                      fit: BoxFit.cover,
                    ),
              onTap: () {
                NavigatorUtils.goBack(context);
              },
            )));
  }
}
