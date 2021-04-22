import 'package:flutter/material.dart';

import '../../../../injection_container.dart';
import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';
import '../../../models/state/app_state.dart';
import '../../../util/app/so_text_style.dart';
import '../../screen/core/so_screen.dart';

class ComponentModel with ChangeNotifier {
  ChangedComponent _changedComponent;

  // Basic Data
  String name = '';
  String componentId = '';
  String rawComponentId = '';

  // State
  CoState state = CoState.Free;

  // Styling
  Color background = Colors.white;
  Color foreground = Colors.black;
  TextStyle fontStyle = TextStyle(fontSize: 16.0, color: Colors.black);
  double textScaleFactor = 1.0;

  Size? _preferredSize;
  Size? _minimumSize;
  Size? _maximumSize;

  bool isVisible = true;
  bool enabled = true;

  String _constraints = "";

  int verticalAlignment = 1;
  int horizontalAlignment = 0;

  String text = "";

  String? classNameEventSourceRef;

  String parentComponentId = '';
  List<Key>? childComponentIds;

  late AppState appState;

  ChangedComponent get changedComponent => _changedComponent;

  set changedComponent(ChangedComponent changedComponent) {
    _changedComponent = changedComponent;

    notifyListeners();
  }

  String get constraints => _constraints;

  set constraints(String constr) {
    if (_constraints != constr) {
      _constraints = constr;
      notifyListeners();
    }
  }

  bool get isForegroundSet => foreground != Colors.black;
  bool get isBackgroundSet => background != Colors.white;
  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;
  Size? get preferredSize => _preferredSize;
  set preferredSize(Size? size) => _preferredSize = size;
  Size? get minimumSize => _minimumSize;
  set minimumSize(Size? size) => _minimumSize = size;
  Size? get maximumSize => _maximumSize;
  set maximumSize(Size? size) => _maximumSize = size;

  ComponentModel({required ChangedComponent changedComponent})
      : _changedComponent = changedComponent,
        componentId = changedComponent.id ?? '',
        appState = sl<AppState>();

  @mustCallSuper
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, _preferredSize);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, _maximumSize);
    minimumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MINIMUM_SIZE, _minimumSize);
    rawComponentId = changedComponent.getProperty<String>(
        ComponentProperty.ID, rawComponentId)!;
    background = changedComponent.getProperty<Color>(
                ComponentProperty.BACKGROUND, background) !=
            null
        ? changedComponent.getProperty<Color>(
            ComponentProperty.BACKGROUND, background)!
        : Colors.white;
    name = changedComponent.getProperty<String>(ComponentProperty.NAME, name)!;
    isVisible = changedComponent.getProperty<bool>(
        ComponentProperty.VISIBLE, isVisible)!;
    fontStyle = SoTextStyle.addFontToTextStyle(
        changedComponent.getProperty<String>(ComponentProperty.FONT, null),
        fontStyle);

    textScaleFactor = appState.applicationStyle?.textScaleFactor ?? 1.0;

    foreground = changedComponent.getProperty<Color>(
        ComponentProperty.FOREGROUND, foreground)!;
    fontStyle = SoTextStyle.addForecolorToTextStyle(foreground, fontStyle)!;
    enabled =
        changedComponent.getProperty<bool>(ComponentProperty.ENABLED, enabled)!;
    verticalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.VERTICAL_ALIGNMENT, verticalAlignment)!;
    horizontalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.HORIZONTAL_ALIGNMENT, horizontalAlignment)!;
    parentComponentId = changedComponent.getProperty<String>(
        ComponentProperty.PARENT, parentComponentId)!;
    _constraints = changedComponent.getProperty<String>(
        ComponentProperty.CONSTRAINTS, constraints)!;
    name = changedComponent.getProperty<String>(ComponentProperty.NAME, name)!;
    text = _changedComponent.getProperty<String>(ComponentProperty.TEXT, text)!;
    classNameEventSourceRef = _changedComponent.getProperty<String>(
        ComponentProperty.CLASS_NAME_EVENT_SOURCE_REF, classNameEventSourceRef);

    this.changedComponent = changedComponent;
  }
}
