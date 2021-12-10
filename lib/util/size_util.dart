import 'package:flutter/material.dart';

class SizeUtil {

  static Size? fromString(String? pSize){
    if(pSize != null){
      List<String> split = pSize.split(",");

      double width = double.parse(split[0]);
      double height = double.parse(split[1]);

      return Size(width, height);
    }
  }
}