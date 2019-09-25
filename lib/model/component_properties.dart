
import 'package:flutter/cupertino.dart';
import 'package:jvx_mobile_v3/utils/jvx_alignment.dart';
import 'package:jvx_mobile_v3/utils/jvx_text_align.dart';

import '../utils/hex_color.dart';

class ComponentProperties {   
  Map<String, dynamic> properties = new Map<String, dynamic>();
  ComponentProperties cellEditorProperties;

  Type typeOfElementsInList<T>(List<T> e) => T;

  ComponentProperties(this.properties) {
    if (this.properties.containsKey("cellEditor")) {
      cellEditorProperties = new ComponentProperties(this.properties["cellEditor"]);
    }
  }

  T getProperty<T>(String propertyName, [T defaultValue]) {
    if (this.properties.containsKey(propertyName)) {
      return convertProperty<T>(this.properties[propertyName]);
    } else {
      if (defaultValue!=null)
        return defaultValue;
      else
        return null;
    }
  }

  T convertProperty<T>(dynamic value) {
    if (value is String) {
      if (HexColor.isHexColor(value) && T == HexColor) {
        return HexColor(value) as T;
      }

      if (T == Size) {
        List<String> sizeString = value.split(",");
        return Size(double.parse(sizeString[0]), double.parse(sizeString[1])) as T;
      }

    } else if (value is int) {
      if (T == TextAlign) {
        return JVxTextAlign.getTextAlignFromInt(value) as T;
      } else if (T == Alignment) {
        return JVxAlignment.getAlignmentFromInt(value) as T;
      }
    } else if (value is List<dynamic>) {
      if (T.toString() == 'List<String>') {
          List<String> newValue = <String>[];
          value.forEach((v) {
            newValue.add(v.toString());
          });
          value = newValue;
      }
    }

    return value;
  }
}
