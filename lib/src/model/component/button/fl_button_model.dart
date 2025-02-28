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

  static const String STYLE_SMALL = "f_small";

  static const String STYLE_SLIDE = "f_slide";

  static const String STYLE_TEXT = "f_text";

  static const String STYLE_SLIDE_RESETTABLE = "f_slide_reset";

  static const String STYLE_SLIDE_AUTO_RESET = "f_slide_auto_reset";

  static const String STYLE_HAPTIC_LIGHT = "f_haptic_light";
  static const String STYLE_HAPTIC_MEDIUM = "f_haptic_medium";
  static const String STYLE_HAPTIC_HEAVY = "f_haptic_heavy";
  static const String STYLE_HAPTIC_CLICK = "f_haptic_click";
  static const String STYLE_HAPTIC = "f_haptic";

  static const String STYLE_HYPERLINK = "hyperlink";
  static const String STYLE_CELL_HYPERLINK = "ui-hyperlink";
  static const String STYLE_MOBILE_GEOLOCATION = "mobile-geolocation";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The model of the label widget.
  FlLabelModel labelModel = FlLabelModel();

  /// If the border is shown.
  bool borderPainted = true;

  /// If, when the borderPainted property is true, to only show the border on mouse over.
  bool borderOnMouseEntered = false;

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

    if (isSmallStyle) {
      return EdgeInsets.zero;
    } else {
      return const EdgeInsets.all(8);
    }
  }

  /// The paddings between the button and its children.
  set paddings(EdgeInsets? value) {
    _paddings = value;
  }

  /// Data provider for QR-Code buttons or telephone button
  String dataProvider = "";

  /// Column name for QR-Code buttons or telephone button
  String columnName = "";

  /// Column name for geolocation button
  String latitudeColumnName = "";

  /// Column name for geolocation button
  String longitudeColumnName = "";

  /// List of supported scan formats
  List<BarcodeFormat>? scanFormats;

  /// If the button is a slider button
  bool get isSlideStyle =>
      styles.contains(STYLE_SLIDE) || styles.contains(STYLE_SLIDE_RESETTABLE) || styles.contains(STYLE_SLIDE_AUTO_RESET);

  /// If the button is a slider button
  bool get isSliderResetable => styles.contains(STYLE_SLIDE_RESETTABLE) || styles.contains(STYLE_SLIDE_AUTO_RESET);

  /// If the button is a slider button
  bool get isSliderAutoResetting => styles.contains(STYLE_SLIDE_AUTO_RESET);

  /// If the button is a text button
  bool get isTextButton => styles.contains(STYLE_TEXT);

  /// Whether the button invokes [HapticFeedback.lightImpact] on press.
  bool get isHapticLight => styles.contains(STYLE_HAPTIC_LIGHT);

  /// Whether the button invokes [HapticFeedback.mediumImpact] on press.
  bool get isHapticMedium => styles.contains(STYLE_HAPTIC_MEDIUM);

  /// Whether the button invokes [HapticFeedback.heavyImpact] on press.
  bool get isHapticHeavy => styles.contains(STYLE_HAPTIC_HEAVY);

  /// Whether the button invokes [HapticFeedback.selectionClick] on press.
  bool get isHapticClick => styles.contains(STYLE_HAPTIC_CLICK);

  /// Whether the button invokes [HapticFeedback.vibrate] on press.
  bool get isHaptic => styles.contains(STYLE_HAPTIC);

  /// If the button has no default paddings and is small.
  bool get isSmallStyle => styles.contains(STYLE_SMALL);

  /// If the button is a hyperlink button
  bool get isHyperLink => styles.contains(STYLE_HYPERLINK) || styles.contains(STYLE_CELL_HYPERLINK);

  /// If the button is a geolocation button
  bool get isGeolocationStyle => styles.contains(STYLE_MOBILE_GEOLOCATION);

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
      return Size(height, height);
    }

    return Size.square(FlTextFieldWidget.TEXT_FIELD_HEIGHT);
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
      pConversion: (imageTextGap) => (imageTextGap! * scaling).toInt(),
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
        pConversion: (value) => ParseUtil.parseMargins(value)! * scaling);

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

    latitudeColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.latitudeColumnName,
      pDefault: defaultModel.latitudeColumnName,
      pCurrent: latitudeColumnName,
    );

    longitudeColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.longitudeColumnName,
      pDefault: defaultModel.longitudeColumnName,
      pCurrent: longitudeColumnName,
    );

    scanFormats = getPropertyValue<List<BarcodeFormat>?>(
      pJson: pJson,
      pKey: ApiObjectProperty.scanFormats,
      pDefault: defaultModel.scanFormats,
      pCurrent: scanFormats,
      pConversion: (e) => (e as List<dynamic>?)
          ?.map((e) => e as String)
          .map<List<BarcodeFormat>?>((e) => ParseUtil.parseScanFormat(e))
          .nonNulls
          .expand((e) => e)
          .toSet()
          .toList(),
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
