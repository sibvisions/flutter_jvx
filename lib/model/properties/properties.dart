import 'dart:convert';
import 'package:flutter/widgets.dart';
import '../../utils/jvx_alignment.dart';
import '../../utils/jvx_text_align.dart';
import 'hex_color.dart';

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
        if (value != null) return utf8convert(value) as T;
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

  String propertyAsString(String property) {
    String result = property.split('.').last.toLowerCase();

    if (result.contains('__')) {
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
        else
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

  static String utf8convert(String text) {
    try {
      List<int> bytes = text.toString().codeUnits;
      return utf8.decode(bytes);
    } catch (e) {
      print("Failed to decode string to utf-8!");
      return text;
    }
  }
}
