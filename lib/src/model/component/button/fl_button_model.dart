import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/button/fl_button_widget.dart';
import 'package:flutter_client/src/model/component/label/fl_label_model.dart';
import 'package:flutter_client/src/model/layout/alignments.dart';
import 'package:flutter_client/util/font_awesome_util.dart';
import 'package:flutter_client/util/parse_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

/// The model for [FlButtonWidget]
class FlButtonModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The model of the label widget.
  FlLabelModel labelModel = FlLabelModel();

  /// The text of the button.
  String text = "";

  /// If the border activates on click.
  bool borderOnMouseEntered = false;

  /// If the border is shown.
  bool borderPainted = false;

  /// The aria label.
  String ariaLabel = "";

  /// If this is the default button to press. // TODO: implement default button behaviour
  bool defaultButton = false;

  /// The image of the button.
  Widget? image;

  /// The gap between image and text if both exist.
  int imageTextGap = 0;

  /// The image when the button gets pressed.
  Widget? mousePressedImage;

  /// The image when the button is currently being pressed down.
  Widget? mouseOverImage;

  /// The margins between the button and its children.
  EdgeInsets margins = const EdgeInsets.fromLTRB(10, 10, 10, 10);

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
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonText = pJson[ApiObjectProperty.text];
    if (jsonText != null) {
      text = jsonText;
    }

    var jsonBorderOnMouseEntered = pJson[ApiObjectProperty.borderOnMouseEntered];
    if (jsonBorderOnMouseEntered != null) {
      borderOnMouseEntered = jsonBorderOnMouseEntered;
    }

    var jsonBorderPainted = pJson[ApiObjectProperty.borderPainted];
    if (jsonBorderPainted != null) {
      borderPainted = jsonBorderPainted;
    }

    var jsonAriaLabel = pJson[ApiObjectProperty.ariaLabel];
    if (jsonAriaLabel != null) {
      ariaLabel = jsonAriaLabel;
    }

    var jsonImage = pJson[ApiObjectProperty.image];
    if (jsonImage != null) {
      if (IFontAwesome.checkFontAwesome(jsonImage)) {
        image = IFontAwesome.getFontAwesomeIcon(jsonImage);
      } else {
        // TODO image
        // image = jsonImage;
      }
    }

    var jsonImageTextGap = pJson[ApiObjectProperty.imageTextGap];
    if (jsonImageTextGap != null) {
      imageTextGap = jsonImageTextGap;
    }

    var jsonMousePressedImage = pJson[ApiObjectProperty.mousePressedImage];
    if (jsonMousePressedImage != null) {
      if (IFontAwesome.checkFontAwesome(jsonMousePressedImage)) {
        mousePressedImage = IFontAwesome.getFontAwesomeIcon(jsonMousePressedImage);
      } else {
        // TODO image
        // image = jsonImage;
      }
    }

    var jsonMouseOverImage = pJson[ApiObjectProperty.mouseOverImage];
    if (jsonMouseOverImage != null) {
      if (IFontAwesome.checkFontAwesome(jsonMouseOverImage)) {
        mouseOverImage = IFontAwesome.getFontAwesomeIcon(jsonMouseOverImage);
      } else {
        // TODO image
        // image = jsonImage;
      }
    }

    var jsonMargins = ParseUtil.parseMargins(pJson[ApiObjectProperty.margins]);
    if (jsonMargins != null) {
      margins = jsonMargins;
    }

    // Label parsing
    // Label alignment gets sent in 2 different keys than when sending a label directly.

    labelModel.text = text;
    labelModel.background = background;
    labelModel.foreground = foreground;
    labelModel.fontName = fontName;
    labelModel.fontSize = fontSize;
    labelModel.isBold = isBold;
    labelModel.isItalic = isItalic;

    Map<String, dynamic> labelJson = <String, dynamic>{};
    labelJson[ApiObjectProperty.horizontalAlignment] = pJson[ApiObjectProperty.horizontalTextPosition];
    labelJson[ApiObjectProperty.verticalAlignment] = pJson[ApiObjectProperty.verticalTextPosition];

    labelModel.applyFromJson(labelJson);
  }
}
