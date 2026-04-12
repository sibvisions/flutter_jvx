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

  static const String STYLE_SECURE = "f_secure";

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

  /// If the button is a secure button
  bool get isSecure => styles.contains(STYLE_SECURE);

  /// Whether the button invokes [HapticUtil.light] on press.
  bool get isHapticLight => styles.contains(STYLE_HAPTIC_LIGHT);

  /// Whether the button invokes [HapticUtil.medium] on press.
  bool get isHapticMedium => styles.contains(STYLE_HAPTIC_MEDIUM);

  /// Whether the button invokes [HapticUtil.heavy] on press.
  bool get isHapticHeavy => styles.contains(STYLE_HAPTIC_HEAVY);

  /// Whether the button invokes [HapticUtil.selection] on press.
  bool get isHapticClick => styles.contains(STYLE_HAPTIC_CLICK);

  /// Whether the button invokes [HapticUtil.vibrate] on press.
  bool get isHaptic => styles.contains(STYLE_HAPTIC);

  /// If the button has no default paddings and is small.
  bool get isSmallStyle => styles.contains(STYLE_SMALL);

  /// If the button is a hyperlink button
  bool get isHyperLink => styles.contains(STYLE_HYPERLINK) || styles.contains(STYLE_CELL_HYPERLINK);

  /// If the button is a geolocation button
  bool get isGeolocationStyle => styles.contains(STYLE_MOBILE_GEOLOCATION);

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
  set background(Color? color) {
    super.background = color;
    labelModel.background = color;
  }

  @override
  set foreground(Color? color) {
    super.foreground = color;
    labelModel.foreground = color;
  }

  @override
  set font(JVxFont? font) {
    super.font = font;
    labelModel.font = font;
  }

  @override
  FlButtonModel get defaultModel => FlButtonModel();

  @override
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    borderOnMouseEntered = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.borderOnMouseEntered,
      defaultValue: defaultModel.borderOnMouseEntered,
      currentValue: borderOnMouseEntered,
    );
    borderPainted = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.borderPainted,
      defaultValue: defaultModel.borderPainted,
      currentValue: borderPainted,
    );
    image = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.image,
      defaultValue: defaultModel.image,
      currentValue: image,
    );
    imageTextGap = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.imageTextGap,
      defaultValue: defaultModel.imageTextGap,
      currentValue: imageTextGap,
      conversion: (imageTextGap) => (imageTextGap! * scaling).toInt(),
    );
    mousePressedImage = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.mousePressedImage,
      defaultValue: defaultModel.mousePressedImage,
      currentValue: mousePressedImage,
    );

    mouseOverImage = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.mouseOverImage,
      defaultValue: defaultModel.mouseOverImage,
      currentValue: mouseOverImage,
    );
    paddings = getPropertyValue(
        json: newJson,
        key: ApiObjectProperty.margins,
        defaultValue: defaultModel._paddings,
        currentValue: _paddings,
        conversion: (value) => ParseUtil.parseMargins(value)! * scaling);

    dataProvider = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.dataRow,
      defaultValue: defaultModel.dataProvider,
      currentValue: dataProvider,
    );

    columnName = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.columnName,
      defaultValue: defaultModel.columnName,
      currentValue: columnName,
    );

    latitudeColumnName = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.latitudeColumnName,
      defaultValue: defaultModel.latitudeColumnName,
      currentValue: latitudeColumnName,
    );

    longitudeColumnName = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.longitudeColumnName,
      defaultValue: defaultModel.longitudeColumnName,
      currentValue: longitudeColumnName,
    );

    scanFormats = getPropertyValue<List<BarcodeFormat>?>(
      json: newJson,
      key: ApiObjectProperty.scanFormats,
      defaultValue: defaultModel.scanFormats,
      currentValue: scanFormats,
      conversion: (e) => (e as List<dynamic>?)
          ?.map((e) => e as String)
          .map<List<BarcodeFormat>?>((e) => ParseUtil.parseScanFormat(e))
          .nonNulls
          .expand((e) => e)
          .toSet()
          .toList(),
    );

    // Label parsing
    // The button has a text position which is not the same as alignment, we copy the text position
    // as alignment for the label

    Map<String, dynamic> labelJson = <String, dynamic>{};

    if (newJson.containsKey(ApiObjectProperty.horizontalTextPosition)) {
      labelJson[ApiObjectProperty.horizontalAlignment] = newJson[ApiObjectProperty.horizontalTextPosition];
    }
    if (newJson.containsKey(ApiObjectProperty.verticalTextPosition)) {
      labelJson[ApiObjectProperty.verticalAlignment] = newJson[ApiObjectProperty.verticalTextPosition];
    }
    if (newJson.containsKey(ApiObjectProperty.text)) {
      labelJson[ApiObjectProperty.text] = newJson[ApiObjectProperty.text];
    }

    if (labelJson.isNotEmpty) {
      labelModel.applyFromJson(labelJson);
    }
  }

  @override
  void applyCellEditorOverrides(Map<String, dynamic> json) {
    super.applyCellEditorOverrides(json);

    Map<String, dynamic> labelJson = Map.from(json);
    //remove alignments because the label is only aligned with horizontalTextPosition and verticalTextPostion, but not
    //with "standard alignments"
    labelJson.remove(ApiObjectProperty.cellEditorHorizontalAlignment);
    labelJson.remove(ApiObjectProperty.cellEditorVerticalAlignment);

    if (labelJson.isNotEmpty) {
      labelModel.applyCellEditorOverrides(labelJson);
    }
  }
}
