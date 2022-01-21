import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/button/fl_button_widget.dart';
import 'package:flutter_client/src/model/component/label/fl_label_model.dart';
import 'package:flutter_client/src/model/layout/alignments.dart';
import 'package:flutter_client/util/font_awesome_util.dart';
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlButtonModel() : super();

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

    // Label parsing
    // Label alignment gets sent in 2 different keys than when sending a label directly.

    pJson[ApiObjectProperty.horizontalAlignment] = pJson[ApiObjectProperty.horizontalTextPosition];
    pJson[ApiObjectProperty.verticalAlignment] = pJson[ApiObjectProperty.verticalTextPosition];

    labelModel.applyFromJson(pJson);
  }
}
