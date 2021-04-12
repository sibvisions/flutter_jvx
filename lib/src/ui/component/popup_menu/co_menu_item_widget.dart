import 'package:flutter/material.dart';

import '../component_widget.dart';
import 'models/menu_item_component_model.dart';

class CoMenuItemWidget extends ComponentWidget {
  final MenuItemComponentModel componentModel;
  CoMenuItemWidget({Key? key, required this.componentModel})
      : super(key: key, componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoMenuItemWidgetState();
}

class CoMenuItemWidgetState extends ComponentWidgetState<CoMenuItemWidget> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
        value: widget.componentModel.name,
        child: Text(widget.componentModel.text),
        enabled: widget.componentModel.enabled);
  }
}
