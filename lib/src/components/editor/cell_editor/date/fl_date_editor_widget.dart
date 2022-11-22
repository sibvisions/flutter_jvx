import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../flutter_jvx.dart';
import '../../../../../util/jvx_colors.dart';
import '../../../../model/component/editor/cell_editor/date/fl_date_editor_model.dart';
import '../../text_field/fl_text_field_widget.dart';

class FlDateEditorWidget<T extends FlDateEditorModel> extends FlTextFieldWidget<T> {
  const FlDateEditorWidget({
    super.key,
    required super.model,
    required super.focusNode,
    required super.textController,
    required super.valueChanged,
    required super.endEditing,
    super.inTable,
    super.hideClearIcon,
  }) : super(keyboardType: TextInputType.none);

  @override
  List<Widget> createSuffixIconItems([bool pForceAll = false]) {
    List<Widget> oldSuffixItems = super.createSuffixIconItems(pForceAll);

    bool isLight = Theme.of(FlutterJVx.getCurrentContext()!).brightness == Brightness.light;

    oldSuffixItems.add(
      Center(
        child: Icon(
          FontAwesomeIcons.calendar,
          size: iconSize,
          color: isLight ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
        ),
      ),
    );

    return oldSuffixItems;
  }
}
