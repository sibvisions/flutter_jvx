import 'package:flutter/material.dart';

import '../layout/i_alignment_constants.dart';
import 'component_widget.dart';
import 'models/selected_component_model.dart';

class CoCheckBoxWidget extends ComponentWidget {
  final SelectedComponentModel componentModel;
  CoCheckBoxWidget({this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoCheckBoxWidgetState();
}

class CoCheckBoxWidgetState extends ComponentWidgetState<CoCheckBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
            widget.componentModel.horizontalAlignment),
        children: <Widget>[
          Checkbox(
            value: widget.componentModel.selected,
            onChanged: (bool change) {
              setState(() {
                widget.componentModel.selected = change;
              });
              if (widget.componentModel.eventAction != null &&
                  widget.componentModel.eventAction) {
                widget.componentModel.onComponentValueChanged(
                    widget.componentModel.name, change);
              }
            },
            tristate: false,
          ),
          widget.componentModel.text != null
              ? SizedBox(
                  width: 0,
                )
              : Container(),
          widget.componentModel.text != null
              ? Text(widget.componentModel.text)
              : Container(),
        ],
      ),
    );
  }
}
