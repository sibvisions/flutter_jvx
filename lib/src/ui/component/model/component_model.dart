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

  DateTime? lastLayout;

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
        lastLayout = changedComponent.created,
        appState = sl<AppState>();

  // @mustCallSuper
  // void updateProperties(
  //     BuildContext context, ChangedComponent changedComponent) {
  //   // preferredSize = changedComponent.getProperty<Size>(ComponentProperty.PREFERRED_SIZE, _preferredSize);
  //   // maximumSize = changedComponent.getProperty<Size>(ComponentProperty.MAXIMUM_SIZE, _maximumSize);
  //   // minimumSize = changedComponent.getProperty<Size>(ComponentProperty.MINIMUM_SIZE, _minimumSize);
  //   // rawComponentId = changedComponent.getProperty<String>(ComponentProperty.ID, rawComponentId)!;
  //   // background = changedComponent.getProperty<Color>(ComponentProperty.BACKGROUND, background) != null ? changedComponent.getProperty<Color>(ComponentProperty.BACKGROUND, background)! : Colors.white;
  //   // name = changedComponent.getProperty<String>(ComponentProperty.NAME, name)!;
  //   // isVisible = changedComponent.getProperty<bool>(ComponentProperty.VISIBLE, isVisible)!;
  //   // fontStyle = SoTextStyle.addFontToTextStyle(changedComponent.getProperty<String>(ComponentProperty.FONT, null),fontStyle);
  //
  //   // textScaleFactor = appState.applicationStyle?.textScaleFactor ?? 1.0;
  //
  //   // foreground = changedComponent.getProperty<Color>(ComponentProperty.FOREGROUND, foreground)!;
  //   // fontStyle = SoTextStyle.addForecolorToTextStyle(foreground, fontStyle)!;
  //   // enabled = changedComponent.getProperty<bool>(ComponentProperty.ENABLED, enabled)!;
  //   // verticalAlignment = changedComponent.getProperty<int>(ComponentProperty.VERTICAL_ALIGNMENT, verticalAlignment)!;
  //   // horizontalAlignment = changedComponent.getProperty<int>(ComponentProperty.HORIZONTAL_ALIGNMENT, horizontalAlignment)!;
  //   // parentComponentId = changedComponent.getProperty<String>(ComponentProperty.PARENT, parentComponentId)!;
  //   // _constraints = changedComponent.getProperty<String>(ComponentProperty.CONSTRAINTS, constraints)!;
  //   // name = changedComponent.getProperty<String>(ComponentProperty.NAME, name)!;
  //   // text = changedComponent.getProperty<String>(ComponentProperty.TEXT, text)!;
  //   // classNameEventSourceRef = _changedComponent.getProperty<String>(ComponentProperty.CLASS_NAME_EVENT_SOURCE_REF, classNameEventSourceRef);
  //
  //   toBeNamed(context, changedComponent);
  // }

  @mustCallSuper
  void updateProperties(BuildContext context, ChangedComponent changedComponent){
    // MetaData
    //    RawComponentId
    String? tempRawComponentId = changedComponent.getProperty<String>(ComponentProperty.ID, null);
    if(tempRawComponentId != null)
      rawComponentId = tempRawComponentId;
    //    ParentId
    String? tempParentComponentId = changedComponent.getProperty<String>(ComponentProperty.PARENT, null);
    if(tempParentComponentId != null)
      parentComponentId = tempParentComponentId;
    //    Name
    String? tempName = changedComponent.getProperty<String>(ComponentProperty.NAME, null);
    if(tempName != null)
      name = tempName;
    //    Enabled
    bool? tempEnabled = changedComponent.getProperty<bool>(ComponentProperty.ENABLED, null);
    if(tempEnabled != null)
      enabled = tempEnabled;
    //    Is Visible
    bool? tempIsVisible = changedComponent.getProperty<bool>(ComponentProperty.VISIBLE, null);
    if(tempIsVisible != null)
      isVisible = tempIsVisible;
    //    ClassNameEventSourceRef
    String? tempClassNameEventSourceRef = _changedComponent.getProperty<String>(ComponentProperty.CLASS_NAME_EVENT_SOURCE_REF, classNameEventSourceRef);
    if(tempClassNameEventSourceRef != null)
      classNameEventSourceRef = tempClassNameEventSourceRef;



    // LayoutData
    //    Preferred Size
    Size? tempPreferredSize = changedComponent.getProperty<Size>(ComponentProperty.PREFERRED_SIZE, null);
    if(tempPreferredSize != null)
      preferredSize = tempPreferredSize;
    //    Maximum Size
    Size? tempMaximumSize = changedComponent.getProperty<Size>(ComponentProperty.MAXIMUM_SIZE, null);
    if(tempMaximumSize != null)
      maximumSize = tempMaximumSize;
    //    MinimumSize
    Size? tempMinimumSize = changedComponent.getProperty<Size>(ComponentProperty.MINIMUM_SIZE, null);
    if(tempMinimumSize != null)
      minimumSize = tempMinimumSize;
    //    Constraints
    String? tempConstraints = changedComponent.getProperty<String>(ComponentProperty.CONSTRAINTS, null);
    if(tempConstraints != null)
      _constraints = tempConstraints;
    //    Horizontal Alignment
    int? tempHorizontalAlignment = changedComponent.getProperty<int>(ComponentProperty.HORIZONTAL_ALIGNMENT, null);
    if(tempHorizontalAlignment != null)
      horizontalAlignment = tempHorizontalAlignment;
    //    Vertical Alignment
    int? tempVerticalAlignment = changedComponent.getProperty<int>(ComponentProperty.VERTICAL_ALIGNMENT, null);
    if(tempVerticalAlignment != null)
      verticalAlignment = tempVerticalAlignment;




    // Appearance
    //    TextScaleFactor
    textScaleFactor = appState.applicationStyle?.textScaleFactor ?? 1.0;
    //    Text
    String? tempText = changedComponent.getProperty<String>(ComponentProperty.TEXT, null);
    if(tempText != null)
      text = tempText;
   //    Foreground Color
    Color? tempForeground = changedComponent.getProperty<Color>(ComponentProperty.FOREGROUND, null);
    if(tempForeground != null)
      foreground = tempForeground;
    //    Background Color
    Color? tempBackground = changedComponent.getProperty<Color>(ComponentProperty.BACKGROUND, null);
    if(tempBackground != null)
      background = tempBackground;

    //    Font Style
    Color? tempTextForeground = changedComponent.getProperty<Color>(ComponentProperty.FOREGROUND, null);
    String? tempFont = changedComponent.getProperty<String>(ComponentProperty.FONT, null);
    if(tempTextForeground != null)
      fontStyle = SoTextStyle.addForecolorToTextStyle(tempTextForeground, fontStyle)!;
    if(tempFont != null)
      fontStyle = SoTextStyle.addFontToTextStyle(tempFont, fontStyle);


    this.changedComponent = changedComponent;
    this.lastLayout = changedComponent.created;
  }
}
