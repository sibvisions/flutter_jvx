import 'package:flutter/material.dart';

import '../layout/i_alignment_constants.dart';
import 'component_widget.dart';
import 'model/selectable_component_model.dart';

class CoCheckBoxWidget extends ComponentWidget {
  final SelectableComponentModel componentModel;

  CoCheckBoxWidget({required this.componentModel})
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
            onChanged: (bool? change) {
              if (change != null) {
                setState(() {
                  widget.componentModel.selected = change;
                });

                if (widget.componentModel.eventAction) {
                  widget.componentModel.onComponentValueChanged(
                      context, widget.componentModel.name, change);
                }
              }
            },
            tristate: false,
          ),
          widget.componentModel.text.isNotEmpty
              ? SizedBox(
                  width: 0,
                )
              : Container(),
          widget.componentModel.text.isNotEmpty
              ? Text(widget.componentModel.text)
              : Container(),
        ],
      ),
    );
  }
}
