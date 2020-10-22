import 'package:flutter/material.dart';

import '../component_widget.dart';
import 'popup_component_model.dart';

class CoPopupMenuWidget extends ComponentWidget {
  CoPopupMenuWidget({Key key, PopupComponentModel componentModel})
      : super(key: key, componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoPopupMenuWidgetState();
}

class CoPopupMenuWidgetState extends ComponentWidgetState<CoPopupMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
