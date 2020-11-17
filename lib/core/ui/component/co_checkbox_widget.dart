import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../models/api/request/set_component_value.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../layout/I_alignment_constants.dart';
import 'component_model.dart';
import 'component_widget.dart';

class CoCheckBoxWidget extends ComponentWidget {
  CoCheckBoxWidget({ComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoCheckBoxWidgetState();
}

class CoCheckBoxWidgetState extends ComponentWidgetState<CoCheckBoxWidget> {
  String text;
  bool selected = false;
  bool eventAction = false;

  @override
  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = changedProperties.getProperty<String>(ComponentProperty.TEXT, text);
    eventAction = changedProperties.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    selected = changedProperties.getProperty<bool>(
        ComponentProperty.SELECTED, selected);
  }

  void valueChanged(dynamic value) {
    SetComponentValue setComponentValue = SetComponentValue(this.name, value, this.appState.clientId);
    BlocProvider.of<ApiBloc>(context).add(setComponentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment:
            IAlignmentConstants.getMainAxisAlignment(this.horizontalAlignment),
        children: <Widget>[
          Checkbox(
            value: this.selected,
            onChanged: (bool change) {
              setState(() {
                this.selected = change;
              });
              if (this.eventAction != null && this.eventAction)
                valueChanged(change);
            },
            tristate: false,
          ),
          text != null
              ? SizedBox(
                  width: 0,
                )
              : Container(),
          text != null ? Text(text) : Container(),
        ],
      ),
    );
  }
}
