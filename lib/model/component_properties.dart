
import 'package:flutter/cupertino.dart';
import 'package:jvx_mobile_v3/utils/jvx_alignment.dart';
import 'package:jvx_mobile_v3/utils/jvx_text_align.dart';

import '../utils/hex_color.dart';

class ComponentProperties {   
  Map<String, dynamic> properties = new Map<String, dynamic>();

  ComponentProperties(this.properties);

  T getProperty<T>(String propertyName, [T defaultValue]) {
    dynamic value;
    if (this.properties.containsKey(propertyName)) {
        value = convertProperty<T>(this.properties[propertyName]);
    }

    if (defaultValue!=null && value==null) {
      return defaultValue;
    }

    return value;
  }

  T convertProperty<T>(dynamic value) {
    if (value is String) {
      if (HexColor.isHexColor(value) && T == HexColor) {
        return HexColor(value) as T;
      }
    } else if (value is int) {
      if (T == TextAlign) {
        return JVxTextAlign.getTextAlignFromInt(value) as T;
      } else if (T == Alignment) {
        return JVxAlignment.getAlignmentFromInt(value) as T;
      }
    }

    return value;
  }
}
