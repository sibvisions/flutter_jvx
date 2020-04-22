import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/uidata.dart';
import '../../utils/text_utils.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/set_component_value.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/component/i_component.dart';
import '../../ui/component/jvx_component.dart';
import '../../ui/widgets/custom_dropdown_button.dart' as custom;
import '../../utils/globals.dart' as globals;

class JVxPopupMenuButton extends JVxComponent implements IComponent {
  String text;
  bool eventAction = false;

  @override
  get preferredSize {
    double width = TextUtils.getTextWidth(TextUtils.averageCharactersTextField, Theme.of(context).textTheme.button).toDouble();
    return Size(width,50);
  }

  @override
  get minimumSize {
    return Size(50,50);
  }

  JVxPopupMenuButton(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = changedProperties.getProperty<String>(ComponentProperty.TEXT, text);
    eventAction = changedProperties.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
  }

  void valueChanged(dynamic value) {
    SetComponentValue setComponentValue = SetComponentValue(this.name, value);
    BlocProvider.of<ApiBloc>(context).dispatch(setComponentValue);
  }

  @override
  Widget getWidget() {
    return Container(
              decoration: BoxDecoration(
            color: background != null ? background : Colors.white
                  .withOpacity(globals.applicationStyle.controlsOpacity),
            borderRadius: BorderRadius.circular(5),
            border: this.eventAction != null && this.eventAction ? (true
                ? Border.all(color: UIData.ui_kit_color_2)
                : null) : Border.all(color: Colors.grey)),
        child: DropdownButtonHideUnderline(
            child: custom.CustomDropdownButton(
      value: text,
      editable: true,
      //editable: this.eventAction != null ? this.eventAction : null,
      onChanged: (String change) =>
          (this.eventAction != null && this.eventAction)
              ? valueChanged(change)
              : null,
      items: <String>[text].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    )));
  }
}
