
import '../utils/hex_color.dart';

class ComponentProperties {   
  Map<String, dynamic> properties = new Map<String, dynamic>();

  ComponentProperties(this.properties);

  dynamic getProperty(String propertyName, [dynamic defaultValue]) {
    dynamic value;
    if (this.properties.containsKey(propertyName)) {
        value = convertProperty(this.properties[propertyName]);
    }

    if (defaultValue!=null && value==null) {
      return defaultValue;
    }

    return value;
  }

  dynamic convertProperty(dynamic value) {
    if (value is String) {

      if (HexColor.isHexColor(value)) {
        return HexColor(value);
      }

    }

    return value;
  }
}
