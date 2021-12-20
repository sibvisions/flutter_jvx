import 'dart:ui';

abstract class ParseUtil{

  /// Will return true if string == "true", false if string == "false"
  /// and null if a null value was provided.
  static bool? parseBoolFromString({String? pBoolString}){
    if(pBoolString != null){
      if(pBoolString == "true"){
        return true;
      } else if(pBoolString == "false"){
        return false;
      }
    }
  }


  /// Parses a [Size] object from a string, will only parse correctly if provided string was formatted :
  /// "x,y" - e.g. 200x400 -> Size(200,400), of provided String was null, returned size will also be null
  static Size? parseSizeFromString({String? pSizeString}){
    if(pSizeString != null){
      List<String> split = pSizeString.split(",");

      double width = double.parse(split[0]);
      double height = double.parse(split[1]);

      return Size(width, height);
    }
  }
}