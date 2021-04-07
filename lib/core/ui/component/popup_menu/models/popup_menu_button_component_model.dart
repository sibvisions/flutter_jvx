import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../injection_container.dart';
import '../../../../models/api/component/changed_component.dart';
import '../../../../models/api/component/component_properties.dart';
import '../../../../utils/app/text_utils.dart';
import '../../../../utils/theme/theme_manager.dart';
import '../../../widgets/util/fontAwesomeChanger.dart';
import '../../models/action_component_model.dart';
import '../co_popup_menu_widget.dart';

class PopupMenuButtonComponentModel extends ActionComponentModel {
  CoPopupMenuWidget menu;
  bool eventAction = false;
  String defaultMenuItem;
  String image;
  Size iconSize = Size(16, 16);
  Widget icon;
  bool network = false;

  PopupMenuButtonComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  get preferredSize {
    double width =
        TextUtils.getTextWidth(TextUtils.averageCharactersTextField, fontStyle)
            .toDouble();
    return Size(width, 60);
  }

  @override
  get minimumSize {
    return Size(50, 50);
  }

  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);

    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    defaultMenuItem = changedComponent.getProperty<String>(
        ComponentProperty.DEFAULT_MENU_ITEM, defaultMenuItem);
    image = changedComponent.getProperty<String>(ComponentProperty.IMAGE);

    if (this.image != null) {
      if (checkFontAwesome(this.image)) {
        icon = convertFontAwesomeTextToIcon(this.image,
            sl<ThemeManager>().themeData.primaryTextTheme.bodyText1.color);
      } else {
        List strinArr =
            List<String>.from(this.image.split(','));
        if (kIsWeb) {
          if (appState.files.containsKey(strinArr[0])) {
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
                this.appState.baseUrl + strinArr[0],
                width: this.iconSize.width,
                height: this.iconSize.height,
              );
            } else {
              icon = Image.memory(
                  base64Decode(this.appState.files[strinArr[0]]),
                  width: this.iconSize.width,
                  height: this.iconSize.height);
            }
          }
        } else {
          File file = File('${this.appState.dir}${strinArr[0]}');
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
  }
}
