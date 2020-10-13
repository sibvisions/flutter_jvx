import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/set_component_value.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/so_text_align.dart';
import '../../utils/text_utils.dart';
import '../../utils/uidata.dart';
import 'component_model.dart';
import 'component_widget.dart';

class CoTextAreaWidget extends ComponentWidget {
  CoTextAreaWidget({ComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoTextAreaWidgetState();
}

class CoTextAreaWidgetState extends ComponentWidgetState<CoTextAreaWidget> {
  TextEditingController _controller = TextEditingController();
  bool valueChanged = false;
  String text;
  bool eventAction = false;
  bool border;
  int horizontalAlignment;
  int columns = 10;

  @override
  get preferredSize {
    double width = TextUtils.getTextWidth(
            TextUtils.getCharactersWithLength(columns),
            Theme.of(context).textTheme.button)
        .toDouble();
    return Size(width, 100);
  }

  @override
  get minimumSize {
    return Size(10, 50);
  }

  @override
  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = changedProperties.getProperty<String>(ComponentProperty.TEXT, text);
    eventAction = changedProperties.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    border =
        changedProperties.getProperty<bool>(ComponentProperty.BORDER, true);
    horizontalAlignment = changedProperties
        .getProperty<int>(ComponentProperty.HORIZONTAL_ALIGNMENT);
    columns =
        changedProperties.getProperty<int>(ComponentProperty.COLUMNS, columns);
  }

  void onTextFieldValueChanged(dynamic newValue) {
    if (text != newValue) {
      text = newValue;
      this.valueChanged = true;
    }
  }

  void onTextFieldEndEditing() {
    if (this.valueChanged) {
      SetComponentValue setComponentValue = SetComponentValue(this.name, text);
      BlocProvider.of<ApiBloc>(context).dispatch(setComponentValue);
      this.valueChanged = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String controllerValue = (text != null ? text.toString() : "");
    _controller.value = _controller.value.copyWith(
        text: controllerValue,
        selection: TextSelection.collapsed(offset: controllerValue.length));

    return Container(
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: this.background != null
                ? this.background
                : Colors.white
                    .withOpacity(globals.applicationStyle.controlsOpacity),
            borderRadius: BorderRadius.circular(
                globals.applicationStyle.cornerRadiusEditors),
            border: border && this.enabled != null && this.enabled
                ? Border.all(color: UIData.ui_kit_color_2)
                : Border.all(color: Colors.grey)),
        child: Container(
          width: 100,
          child: TextField(
            textAlign:
                SoTextAlign.getTextAlignFromInt(this.horizontalAlignment),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(12), border: InputBorder.none),
            style: TextStyle(
                color: this.enabled
                    ? (this.foreground != null ? this.foreground : Colors.black)
                    : Colors.grey[700]),
            // key: this.componentId,
            controller: _controller,
            minLines: null,
            maxLines: 1,
            keyboardType: TextInputType.text,
            onEditingComplete: onTextFieldEndEditing,
            onChanged: onTextFieldValueChanged,
            readOnly: !this.enabled,
          ),
        ),
      ),
    );
  }
}
