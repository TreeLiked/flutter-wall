// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// // import 'package:photo_manager/photo_manager.dart';
//
// class AssetImageWidget extends StatefulWidget {
//   final AssetEntity assetEntity;
//   final double width;
//   final double height;
//   final BoxFit boxFit;
//
//   const AssetImageWidget({
//     Key key,
//     @required this.assetEntity,
//     this.width,
//     this.height,
//     this.boxFit,
//   }) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() {
//     return AssetImageWidgetState(assetEntity, width, height, boxFit);
//   }
// }
//
// class AssetImageWidgetState extends State<AssetImageWidget> {
//   final AssetEntity assetEntity;
//   final double width;
//   final double height;
//   final BoxFit boxFit;
//
//   AssetImageWidgetState(this.assetEntity, this.width, this.height, this.boxFit);
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.assetEntity == null) {
//       return _buildContainer();
//     }
//
//     print(
//         "assetEntity.width = ${widget.assetEntity.width} , assetEntity.height = ${widget.assetEntity.height}");
//
//     return FutureBuilder<Uint8List>(
//       builder: (BuildContext context, snapshot) {
//         if (snapshot.hasData) {
//           return _buildContainer(
//             child: Image.memory(
//               snapshot.data,
//               width: widget.width,
//               height: widget.height,
//               fit: widget.boxFit,
//             ),
//           );
//         } else {
//           return _buildContainer();
//         }
//       },
//       future: widget.assetEntity.thumbDataWithSize(
//         widget.width.toInt(),
//         widget.height.toInt(),
//       ),
//     );
//   }
//
//   Widget _buildContainer({Widget child}) {
//     child ??= Container();
//     return Container(
//       width: widget.width,
//       height: widget.height,
//       child: child,
//     );
//   }
// }
