import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:image_crop/image_crop.dart';

class ImageCropContainer extends StatefulWidget {
  ImageCropContainer({
    @required this.cropKey,
    @required this.file,
  });

  final File file;
  final GlobalKey<CropState> cropKey;

  @override
  _ImageCropContainerState createState() => _ImageCropContainerState();
}

class _ImageCropContainerState extends State<ImageCropContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // widget.file?.delete();

    return Scaffold(
        appBar: MyAppBar(
          backgroundColor: Colors.black,
          actionName: "完成",
          onPressed: () async {
            final scale = widget.cropKey.currentState.scale;
            final area = widget.cropKey.currentState.area;
            if (area == null) {
              // cannot crop, widget is not setup
              return;
            }

            // scale up to use maximum possible number of pixels
            // this will sample image in higher resolution to make cropped image larger
            // final sample = await ImageCrop.sampleImage(
            //   file: _file,
            //   preferredSize: (2000 / scale).round(),
            // );
            final sample = await ImageCrop.sampleImage(
              file: widget.file,
              preferredSize: (2000 / scale).round(),
            );

            final file = await ImageCrop.cropImage(
              file: sample,
              area: area,
            );
            sample.delete();
            NavigatorUtils.goBackWithParams(context, file);
          },
        ),
        body: Container(
          color: Colors.black,
          child: Crop(
              key: widget.cropKey,
              image: FileImage(widget.file),
              aspectRatio: 1),
        ));
  }
}
