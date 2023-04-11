/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

part of 'package:flutter_jvx/src/model/component/fl_component_model.dart';

/// The model for [FlButtonWidget]
class FlButtonModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const String NO_MIN_SIZE = "f_no_min_size";

  static const String SLIDE_STYLE = "f_slide";

  static const String TEXT_STYLE = "f_text";

  static const String SLIDE_RESETABLE_STYLE = "f_slide_reset";

  static const String SLIDE_AUTO_RESET_STYLE = "f_slide_auto_reset";

  static const String HAPTIC_LIGHT = "f_haptic_light";
  static const String HAPTIC_MEDIUM = "f_haptic_medium";
  static const String HAPTIC_HEAVY = "f_haptic_heavy";
  static const String HAPTIC_CLICK = "f_haptic_click";
  static const String HAPTIC = "f_haptic";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The model of the label widget.
  FlLabelModel labelModel = FlLabelModel();

  /// If the border is shown.
  bool borderPainted = true;

  /// If, when the borderPainted property is true, to only show the border on mouse over.
  bool borderOnMouseEntered = false;

  /// The aria label.
  String ariaLabel = "";

  /// If this is the default button to press.
  bool defaultButton = false;

  /// The image of the button.
  String? image;

  /// The gap between image and text if both exist.
  int imageTextGap = 5;

  /// The image when the button gets pressed.
  String? mousePressedImage;

  /// The image when the button is currently being pressed down.
  String? mouseOverImage;

  /// The paddings between the button and its children.
  EdgeInsets? _paddings;

  /// The paddings between the button and its children.
  EdgeInsets get paddings {
    if (_paddings != null) {
      return _paddings!;
    }

    if (hasNoMinSize) {
      return EdgeInsets.zero;
    } else {
      return const EdgeInsets.fromLTRB(10, 10, 10, 10);
    }
  }

  /// The paddings between the button and its children.
  set paddings(EdgeInsets value) {
    _paddings = value;
  }

  /// Dataprovider for QR-Code buttons or telephone button
  String dataProvider = "";

  /// Columnname for QR-Code buttons or telephone button
  String columnName = "";

  /// If the button is a slider button
  bool get isSlideStyle =>
      styles.contains(SLIDE_STYLE) || styles.contains(SLIDE_RESETABLE_STYLE) || styles.contains(SLIDE_AUTO_RESET_STYLE);

  /// If the button is a slider button
  bool get isSliderResetable => styles.contains(SLIDE_RESETABLE_STYLE) || styles.contains(SLIDE_AUTO_RESET_STYLE);

  /// If the button is a slider button
  bool get isSliderAutoResetting => styles.contains(SLIDE_AUTO_RESET_STYLE);

  /// If the button is a text button
  bool get isTextButton => styles.contains(TEXT_STYLE);

  /// Whether the button invokes [HapticFeedback.lightImpact] on press.
  bool get isHapticLight => styles.contains(HAPTIC_LIGHT);

  /// Whether the button invokes [HapticFeedback.mediumImpact] on press.
  bool get isHapticMedium => styles.contains(HAPTIC_MEDIUM);

  /// Whether the button invokes [HapticFeedback.heavyImpact] on press.
  bool get isHapticHeavy => styles.contains(HAPTIC_HEAVY);

  /// Whether the button invokes [HapticFeedback.selectionClick] on press.
  bool get isHapticClick => styles.contains(HAPTIC_CLICK);

  /// Whether the button invokes [HapticFeedback.vibrate] on press.
  bool get isHaptic => styles.contains(HAPTIC);

  /// If the button has no flutter default minimum size.
  bool get hasNoMinSize => styles.contains(NO_MIN_SIZE);

  /// If the button is a hyperlink button
  bool get isHyperLink => styles.contains("hyperlink");

  @override
  Size? get minimumSize {
    if (_minimumSize != null) {
      return _minimumSize;
    }

    if (isSlideStyle) {
      double height = kMinInteractiveDimension;
      if (Frame.isWebFrame()) {
        height = 32;
      }
      return Size(130, height);
    }

    if (hasNoMinSize) {
      return null;
    }

    if (Frame.isWebFrame()) {
      // 32 is the wanted height of our dense Textfields in the webframe
      return const Size.square(32);
    } else {
      return const Size.square(kMinInteractiveDimension);
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlButtonModel() : super() {
    labelModel.verticalAlignment = VerticalAlignment.CENTER;
    labelModel.horizontalAlignment = HorizontalAlignment.RIGHT;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  set background(Color? pColor) {
    super.background = pColor;
    labelModel.background = pColor;
  }

  @override
  set foreground(Color? pColor) {
    super.foreground = pColor;
    labelModel.foreground = pColor;
  }

  @override
  set font(JVxFont pFont) {
    super.font = pFont;
    labelModel.font = pFont;
  }

  @override
  FlButtonModel get defaultModel => FlButtonModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    borderOnMouseEntered = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.borderOnMouseEntered,
      pDefault: defaultModel.borderOnMouseEntered,
      pCurrent: borderOnMouseEntered,
    );
    borderPainted = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.borderPainted,
      pDefault: defaultModel.borderPainted,
      pCurrent: borderPainted,
    );

    ariaLabel = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.ariaLabel,
      pDefault: defaultModel.ariaLabel,
      pCurrent: ariaLabel,
    );

    image = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.image,
      pDefault: defaultModel.image,
      pCurrent: image,
    );
    imageTextGap = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.imageTextGap,
      pDefault: defaultModel.imageTextGap,
      pCurrent: imageTextGap,
      pConversion: (imageTextGap) => (imageTextGap! * ConfigController().getScaling()).toInt(),
    );
    mousePressedImage = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.mousePressedImage,
      pDefault: defaultModel.mousePressedImage,
      pCurrent: mousePressedImage,
    );

    mouseOverImage = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.mouseOverImage,
      pDefault: defaultModel.mouseOverImage,
      pCurrent: mouseOverImage,
    );
    paddings = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.margins,
        pDefault: defaultModel._paddings,
        pCurrent: _paddings,
        pConversion: (value) => ParseUtil.parseMargins(value)! * ConfigController().getScaling());

    dataProvider = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dataRow,
      pDefault: defaultModel.dataProvider,
      pCurrent: dataProvider,
    );

    columnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.columnName,
      pDefault: defaultModel.columnName,
      pCurrent: columnName,
    );

    // Label parsing
    // Label alignment gets sent in 2 different keys than when sending a label directly.

    Map<String, dynamic> labelJson = <String, dynamic>{};
    if (pJson.containsKey(ApiObjectProperty.horizontalTextPosition)) {
      labelJson[ApiObjectProperty.horizontalAlignment] = pJson[ApiObjectProperty.horizontalTextPosition];
    }
    if (pJson.containsKey(ApiObjectProperty.verticalTextPosition)) {
      labelJson[ApiObjectProperty.verticalAlignment] = pJson[ApiObjectProperty.verticalTextPosition];
    }
    if (pJson.containsKey(ApiObjectProperty.text)) {
      labelJson[ApiObjectProperty.text] = pJson[ApiObjectProperty.text];
    }

    labelModel.applyFromJson(labelJson);
  }

  @override
  void applyCellEditorOverrides(Map<String, dynamic> pJson) {
    super.applyCellEditorOverrides(pJson);
    labelModel.applyCellEditorOverrides(pJson);
  }
}
