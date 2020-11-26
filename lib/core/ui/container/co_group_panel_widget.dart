import 'package:flutter/material.dart';

import '../component/models/component_model.dart';
import 'co_container_widget.dart';
import 'co_scroll_panel_layout.dart';
import 'models/group_panel_component_model.dart';

class CoGroupPanelWidget extends CoContainerWidget {
  CoGroupPanelWidget({@required ComponentModel componentModel})
      : super(componentModel: componentModel);

  State<StatefulWidget> createState() => CoGroupPanelWidgetState();
}

class CoGroupPanelWidgetState extends CoContainerWidgetState {
  BoxConstraints _calculateConstraints(BoxConstraints constraints) {
    return BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: constraints.minHeight == constraints.maxHeight
            ? ((constraints.maxHeight - 31) < 0
                ? 0
                : (constraints.maxHeight - 31))
            : constraints.minHeight,
        maxHeight: (constraints.maxHeight - 31) < 0
            ? 0
            : (constraints.maxHeight - 31));
  }

  @override
  Widget build(BuildContext context) {
    GroupPanelComponentModel componentModel = widget.componentModel;

    Widget child;
    if (componentModel.layout != null) {
      child = componentModel.layout as Widget;
      if (componentModel.layout.setState != null) {
        componentModel.layout.setState(() {});
      }
    } else if (componentModel.components.isNotEmpty) {
      child = Column(
        children: componentModel.components,
      );
    }

    if (child != null) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxHeight != double.infinity) {
          constraints = _calculateConstraints(constraints);
        }
        return SingleChildScrollView(
          child: Container(
              child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      componentModel.text,
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              CoScrollPanelLayout(
                preferredConstraints: CoScrollPanelConstraints(constraints),
                children: [
                  CoScrollPanelLayoutId(
                      constraints: CoScrollPanelConstraints(constraints),
                      child: Card(
                          color: componentModel.appState.applicationStyle !=
                                  null
                              ? Colors.white.withOpacity(componentModel
                                  .appState.applicationStyle?.controlsOpacity)
                              : null,
                          margin: EdgeInsets.all(5),
                          elevation: 2.0,
                          child: child,
                          shape:
                              componentModel.appState.applicationStyle != null
                                  ? componentModel
                                      .appState.applicationStyle?.containerShape
                                  : RoundedRectangleBorder()))
                ],
              )
            ],
          )),
        );
      });
    } else {
      return new Container();
    }
  }
}
