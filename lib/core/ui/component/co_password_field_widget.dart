import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../models/api/request/set_component_value.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../../utils/app/so_text_align.dart';
import '../../utils/app/text_utils.dart';
import 'component_model.dart';
import 'component_widget.dart';

class CoPasswordFieldWidget extends ComponentWidget {
  CoPasswordFieldWidget({ComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoPasswordFieldWidgetState();
}

class CoPasswordFieldWidgetState extends ComponentWidgetState {
  TextEditingController _controller = TextEditingController();
  bool valueChanged = false;
  FocusNode node = FocusNode();
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
    return Size(width, 50);
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

    node.addListener(() {
      if (!node.hasFocus) onTextFieldEndEditing();
    });
  }

  void onTextFieldValueChanged(dynamic newValue) {
    if (text != newValue) {
      text = newValue;
      this.valueChanged = true;
    }
  }

  void onTextFieldEndEditing() {
    TextUtils.unfocusCurrentTextfield(context);

    if (this.valueChanged) {
      SetComponentValue setComponentValue =
          SetComponentValue(this.name, text, this.appState.clientId);
      BlocProvider.of<ApiBloc>(context).add(setComponentValue);
      this.valueChanged = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String controllerValue = (text != null ? text.toString() : "");
    _controller.value = _controller.value.copyWith(
        text: controllerValue,
        selection: TextSelection.collapsed(offset: controllerValue.length));

    return DecoratedBox(
      decoration: BoxDecoration(
          color: this.background != null
              ? this.background
              : Colors.white
                  .withOpacity(this.appState.applicationStyle?.controlsOpacity),
          borderRadius: BorderRadius.circular(
              this.appState.applicationStyle?.cornerRadiusEditors),
          border: border && this.enabled != null && this.enabled
              ? Border.all(color: Theme.of(context).primaryColor)
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
            controller: _controller,
            minLines: null,
            maxLines: 1,
            keyboardType: TextInputType.text,
            onEditingComplete: onTextFieldEndEditing,
            onChanged: onTextFieldValueChanged,
            focusNode: node,
            readOnly: !this.enabled,
            obscureText: true),
      ),
    );
  }
}
