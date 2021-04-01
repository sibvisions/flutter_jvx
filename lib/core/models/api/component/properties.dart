import 'package:flutter/widgets.dart';

import '../../../utils/app/so_alignment.dart';
import '../../../utils/app/so_text_align.dart';
import '../../../utils/theme/hex_color.dart';

class Properties {
  Map<String, dynamic> _properties = new Map<String, dynamic>();

  Properties(this._properties);

  bool hasProperty(String propertyName) {
    return this._properties.containsKey(propertyName);
  }

  void removeProperty(String propertyName) {
    if (this.hasProperty(propertyName)) this._properties.remove(propertyName);
  }

  T getProperty<T>(String propertyName, [T defaultValue]) {
    if (this._properties.containsKey(propertyName)) {
      return _convertProperty<T>(this._properties[propertyName]);
    } else {
      if (defaultValue != null)
        return defaultValue;
      else
        return null;
    }
  }

  T _convertProperty<T>(dynamic value) {
    if (value is String) {
      if (HexColor.isHexColor(value) && T == HexColor) {
        return HexColor(value) as T;
      }

      if (T == Size) {
        List<String> sizeString = value.split(",");
        return Size(double.parse(sizeString[0]), double.parse(sizeString[1]))
            as T;
      } else if (T == bool) {
        return (value.toLowerCase() == 'true') as T;
      } else if (T == String) {
        if (value != null) return value as T;
      }
    } else if (value is int) {
      if (T == TextAlign) {
        return SoTextAlign.getTextAlignFromInt(value) as T;
      } else if (T == Alignment) {
        return SoAlignment.getAlignmentFromInt(value) as T;
      }
    } else if (value is List<dynamic>) {
      if (T.toString() == 'List<String>') {
        List<String> newValue = <String>[];
        value.forEach((v) {
          newValue.add(v.toString());
        });
        value = newValue;
      }
    } else if (value is bool) {
      if (T == int) {
        if (value)
          return 1 as T;
        else
          return 0 as T;
      }
    }

    return value;
  }

  static String propertyAsString(String property) {
    String result = property.split('.').last.toLowerCase();

    if (result.contains('___')) {
      result = result.replaceAll('___', '?');

      result = result.replaceAll('__', '.');

      result.split('_').asMap().forEach((i, p) {
        p = p.replaceAll('\$', '~');
        if (i == 0)
          result = p;
        else
          result += '${p[0].toUpperCase()}${p.substring(1)}';
      });

      result = result.replaceAll('?', '_');
    } else if (result.contains('__')) {
      result.split('__').asMap().forEach((i, p) {
        p = p.replaceAll('\$', '~');
        if (i == 0)
          result = p;
        else
          result += '.${p.toLowerCase()}';
      });

      result.split('_').asMap().forEach((i, p) {
        p = p.replaceAll('\$', '~');
        if (i == 0)
          result = p;
        else if (p.isNotEmpty)
          result += '${p[0].toUpperCase()}${p.substring(1)}';
      });
    } else if (result.contains('_')) {
      result.split('_').asMap().forEach((i, p) {
        p = p.replaceAll('\$', '~');
        if (i == 0)
          result = p;
        else
          result += '${p[0].toUpperCase()}${p.substring(1)}';
      });
    } else {
      result = result.replaceAll('\$', '~');
    }

    return result;
  }
}
