import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/button/fl_button_widget.dart';
import 'package:flutter_client/src/components/label/fl_label_widget.dart';
import 'package:flutter_client/src/model/component/button/fl_button_model.dart';
import 'package:flutter_client/src/model/component/label/fl_label_model.dart';
import 'package:flutter_client/src/model/layout/alignments.dart';
import 'package:flutter_client/util/font_awesome_util.dart';
import 'package:flutter_client/util/parse_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../model/command/api/open_screen_command.dart';
import '../../model/menu/menu_item_model.dart';
import '../../service/ui/i_ui_service.dart';

class AppMenuItem extends StatelessWidget {
  const AppMenuItem({
    Key? key,
    required this.menuItemModel,
    required this.uiService,
  }) : super(key: key);

  final IUiService uiService;
  final MenuItemModel menuItemModel;

  _onMenuItemClick() {
    OpenScreenCommand openScreenCommand =
        OpenScreenCommand(componentId: menuItemModel.componentId, reason: "MenuItem pressed");
    uiService.sendCommand(openScreenCommand);
  }

  FlLabelModel _createLabelModel(){
    FlLabelModel model = FlLabelModel();

    model.text = menuItemModel.label;
    model.verticalAlignment = VerticalAlignment.CENTER;
    model.horizontalAlignment = HorizontalAlignment.CENTER;
    model.isBold = true;
    model.isItalic = true;



    return model;
  }

  FlButtonModel _createButtonModel(){

    FlButtonModel model = FlButtonModel();

    model.labelModel.text = menuItemModel.label;
    model.labelModel.verticalAlignment = VerticalAlignment.TOP;
    model.labelModel.horizontalAlignment = HorizontalAlignment.CENTER;
    model.labelModel.isBold = true;
    model.imageTextGap = 5;

    if(menuItemModel.image != null && IFontAwesome.checkFontAwesome(menuItemModel.image!)){
      model.image = IFontAwesome.getFontAwesomeIcon(menuItemModel.image!);
    }


    return model;
  }

  @override
  Widget build(BuildContext context) {
    return FlButtonWidget(
      model: _createButtonModel(),
      onPress: _onMenuItemClick,
    );
  }


  // Card(
  // elevation: 5,
  // child: Column(
  // mainAxisAlignment: MainAxisAlignment.center,
  // children: [
  // FaIcon(menuItemModel.image != null ? IFontAwesome.ICONS[menuItemModel.image]! : FontAwesomeIcons.exclamationTriangle),
  // FlLabelWidget(
  // model: _createLabelModel(),
  // ),
  // ],
  //
  // ),
  // ),
}
