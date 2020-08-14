import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_creator.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/set_component_value.dart';
import '../../utils/so_text_align.dart';
import '../../utils/uidata.dart';
import '../../utils/text_utils.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import 'i_component.dart';
import 'component.dart';
import '../../utils/globals.dart' as globals;

class CoTextArea extends Component implements IComponent {
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
    return Size(width, 100);
  }

  @override
  get minimumSize {
    return Size(10, 50);
  }

  CoTextArea(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  factory CoTextArea.withCompContext(ComponentContext componentContext) {
    return CoTextArea(componentContext.globalKey, componentContext.context);
  }

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
    node.unfocus();

    if (this.valueChanged) {
      SetComponentValue setComponentValue = SetComponentValue(this.name, text);
      BlocProvider.of<ApiBloc>(context).dispatch(setComponentValue);
      this.valueChanged = false;
    }
  }

  @override
  Widget getWidget() {
    String controllerValue = (text != null ? text.toString() : "");
    _controller.value = _controller.value.copyWith(
        text: controllerValue,
        selection: TextSelection.collapsed(offset: controllerValue.length));

    return DecoratedBox(
      decoration: BoxDecoration(
          color: this.background != null
              ? this.background
              : Colors.white
                  .withOpacity(globals.applicationStyle.controlsOpacity),
          borderRadius: BorderRadius.circular(
              globals.applicationStyle.cornerRadiusEditors),
          border: border && this.eventAction != null && this.eventAction
              ? Border.all(color: UIData.ui_kit_color_2)
              : Border.all(color: Colors.grey)),
      child: TextField(
        textAlign: SoTextAlign.getTextAlignFromInt(this.horizontalAlignment),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(12), border: InputBorder.none),
        style: TextStyle(
            color: this.eventAction
                ? (this.foreground != null ? this.foreground : Colors.black)
                : Colors.grey[700]),
        key: this.componentId,
        controller: _controller,
        minLines: null,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        onEditingComplete: onTextFieldEndEditing,
        onChanged: onTextFieldValueChanged,
        focusNode: node,
        readOnly: !this.eventAction,
      ),
    );
  }
}
