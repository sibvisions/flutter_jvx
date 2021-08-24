import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterclient/src/util/icon/font_awesome_changer.dart';
import 'package:flutterclient/src/util/image/image_loader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomIcon extends StatelessWidget {
  final String image;
  final Size? prefferedSize;
  final Color? color;

  CustomIcon({required this.image, this.prefferedSize, this.color});

  @override
  Widget build(BuildContext context) {
    if (checkFontAwesome(image)) {
      if (!image.contains("size=") && this.prefferedSize == null) {
        return convertFontAwesomeTextToIcon(
            image, color != null ? color! : Theme.of(context).primaryColor);
      } else {
        return _iconBuilder(
          formatFontAwesomeText(image),
          image,
          context,
        );
      }
    }
    Image? imgWidget = getImage(context, image);

    if (imgWidget != null) return imgWidget;

    return Container();
  }

  Size? getSize(String image) {
    List<String> arr = image.split(',');

    if (arr.length >= 3 &&
        double.tryParse(arr[1]) != null &&
        double.tryParse(arr[2]) != null)
      return Size(double.parse(arr[1]), double.parse(arr[2]));

    return null;
  }

  Image? getImage(BuildContext context, String image) {
    Image? img;
    List<String> arr = image.split(',');
    Size? size = this.prefferedSize;

    if (size == null) size = getSize(image);

    if (size!.width > MediaQuery.of(context).size.width) {
      size = Size(MediaQuery.of(context).size.width / 2, size.width);
    }

    if (arr.length > 0)
      img = ImageLoader().loadImage('${arr[0]}', size.width, size.height);
 
    return img;
  }

  FaIcon _iconBuilder(Map data, String contentString, BuildContext context) {
    double? widgetSize = getSize(contentString)?.height;

    if (widgetSize == null && data['size'] != null && prefferedSize == null) {
      List<String> arr = data['size'].split(',');
      if (arr.length > 0 && double.tryParse(arr[0]) != null)
        widgetSize = double.parse(arr[0]);
    } else if (widgetSize == null) {
      widgetSize = prefferedSize?.height ?? 32;
    }

    FaIcon icon = new FaIcon(
      data['icon'],
      size: widgetSize,
      color: color != null ? color : Theme.of(context).primaryColor,
      key: data['key'],
      textDirection: data['textDirection'],
    );

    return icon;
  }
}
