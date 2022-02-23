import 'package:flutter/material.dart';
import '../../../../util/constants/i_color.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../components/button/fl_button_widget.dart';
import '../label/fl_label_model.dart';
import '../../layout/alignments.dart';
import '../../../../util/font_awesome_util.dart';
import '../../../../util/parse_util.dart';

import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

/// The model for [FlButtonWidget]
class FlButtonModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The model of the label widget.
  FlLabelModel labelModel = FlLabelModel();

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
  int imageTextGap = 5;

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
        FaIcon icon = IFontAwesome.getFontAwesomeIcon(jsonImage);
        if (_isGrey) {
          image = FaIcon(icon.icon, size: icon.size, color: IColorConstants.COMPONENT_DISABLED);
        } else {
          image = icon;
        }
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
        FaIcon icon = IFontAwesome.getFontAwesomeIcon(jsonMousePressedImage);
        if (_isGrey) {
          mousePressedImage = FaIcon(icon.icon, size: icon.size, color: IColorConstants.COMPONENT_DISABLED);
        } else {
          mousePressedImage = icon;
        }
      } else {
        // TODO image
        // image = jsonImage;
      }
    }

    var jsonMouseOverImage = pJson[ApiObjectProperty.mouseOverImage];
    if (jsonMouseOverImage != null) {
      if (IFontAwesome.checkFontAwesome(jsonMouseOverImage)) {
        FaIcon icon = IFontAwesome.getFontAwesomeIcon(jsonMouseOverImage);
        if (_isGrey) {
          mouseOverImage = FaIcon(icon.icon, size: icon.size, color: IColorConstants.COMPONENT_DISABLED);
        } else {
          mouseOverImage = icon;
        }
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

    // If the button is disabled
    if (_isGrey) {
      foreground = IColorConstants.COMPONENT_DISABLED;
    }

    labelModel.background = background;
    labelModel.foreground = foreground;
    labelModel.fontName = fontName;
    labelModel.fontSize = fontSize;
    labelModel.isBold = isBold;
    labelModel.isItalic = isItalic;

    Map<String, dynamic> labelJson = <String, dynamic>{};
    labelJson[ApiObjectProperty.horizontalAlignment] = pJson[ApiObjectProperty.horizontalTextPosition];
    labelJson[ApiObjectProperty.verticalAlignment] = pJson[ApiObjectProperty.verticalTextPosition];
    labelJson[ApiObjectProperty.text] = pJson[ApiObjectProperty.text];

    labelModel.applyFromJson(labelJson);
  }

  bool get _isGrey {
    return !(isEnabled && isFocusable);
  }
}
