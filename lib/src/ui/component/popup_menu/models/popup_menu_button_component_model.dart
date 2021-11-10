import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../injection_container.dart';
import '../../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../../models/api/response_objects/response_data/component/component_properties.dart';
import '../../../../util/app/so_text_align.dart';
import '../../../../util/app/text_utils.dart';
import '../../../../util/color/color_extension.dart';
import '../../../../util/icon/font_awesome_changer.dart';
import '../../../../util/theme/theme_manager.dart';
import '../../co_action_component_widget.dart';
import '../../model/action_component_model.dart';
import '../co_popup_menu_widget.dart';

class PopupMenuButtonComponentModel extends ActionComponentModel {
  CoPopupMenuWidget? menu;
  bool eventAction = false;
  String? defaultMenuItem;
  String? image;
  Size iconSize = Size(16, 16);
  Widget? icon;
  bool network = false;
  double iconPadding = 10;
  int _horizontalTextPosition = 1;
  EdgeInsets margin = EdgeInsets.zero;

  TextAlign get horizontalTextPosition {
    return SoTextAlign.getTextAlignFromInt(_horizontalTextPosition);
  }

  PopupMenuButtonComponentModel(
      {required ChangedComponent changedComponent,
      required ActionCallback onAction})
      : super(changedComponent: changedComponent, onAction: onAction);

  @override
  get preferredSize {
    double width = 44;
    double height = 36;

    if (this.image != null) {
      width += iconSize.width + iconPadding * 2;
    }

    Size size = TextUtils.getTextSize(text, fontStyle, textScaleFactor);
    return Size(size.width + width + margin.horizontal,
        size.height + height + margin.vertical);
  }

  @override
  get minimumSize {
    return Size(50, 50);
  }

  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction)!;
    defaultMenuItem = changedComponent.getProperty<String>(
        ComponentProperty.DEFAULT_MENU_ITEM, defaultMenuItem);
    image =
        changedComponent.getProperty<String>(ComponentProperty.IMAGE, image);
    _horizontalTextPosition = changedComponent.getProperty<int>(
        ComponentProperty.HORIZONTAL_TEXT_POSITION, _horizontalTextPosition)!;

    if (this.image != null) {
      if (checkFontAwesome(image!)) {
        icon = convertFontAwesomeTextToIcon(
            image!, sl<ThemeManager>().value.primaryColor.textColor());
      } else {
        List strinArr = List<String>.from(image!.split(','));
        if (kIsWeb) {
          if (appState.fileConfig.files.containsKey(strinArr[0])) {
            if (strinArr.length >= 3 &&
                double.tryParse(strinArr[1]) != null &&
                double.tryParse(strinArr[2]) != null) {
              this.iconSize =
                  Size(double.parse(strinArr[1]), double.parse(strinArr[2]));

              if (strinArr[3] != null) {
                network = strinArr[3].toLowerCase() == 'true';
              }
            }
            if (network) {
              icon = Image.network(
                appState.serverConfig!.baseUrl + strinArr[0],
                width: this.iconSize.width,
                height: this.iconSize.height,
              );
            } else {
              icon = Image.memory(
                  base64Decode(appState.fileConfig.files[strinArr[0]]!),
                  width: this.iconSize.width,
                  height: this.iconSize.height);
            }
          }
        } else {
          File file = File('${this.appState.baseDirectory}${strinArr[0]}');
          if (file.existsSync()) {
            Size size = Size(16, 16);

            if (strinArr.length >= 3 &&
                double.tryParse(strinArr[1]) != null &&
                double.tryParse(strinArr[2]) != null)
              size = Size(double.parse(strinArr[1]), double.parse(strinArr[2]));
            icon = Image.memory(
              file.readAsBytesSync(),
              width: size.width,
              height: size.height,
            );
          }
        }
      }
    }

    super.updateProperties(context, changedComponent);
  }
}
