import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumericTextFormatter extends TextInputFormatter {
  final String? locale;
  final int? precision;
  final int? length;
  final int? scale;
  final bool? signed;
  final NumberFormat numberFormatter;

  NumericTextFormatter({String? numberFormat, this.locale, this.precision, this.length, this.scale, this.signed})
      : numberFormatter = NumberFormat(numberFormat, locale);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty && newValue.text.compareTo(oldValue.text) != 0) {
      String newString = newValue.text;

      try {
        RegExp regEndingZeros = RegExp(r"^.*" + numberFormatter.symbols.DECIMAL_SEP + r".*(?<!0)(0*)$");
        String endingZeroes = regEndingZeros.firstMatch(newString)?.group(1) ?? "";
        num? number = convertToNumber(newString);
        if (number != null) {
          if (!number.toString().contains(".") && endingZeroes.isNotEmpty) {
            endingZeroes = ".$endingZeroes";
          }
          if (precision != null && precision! > 0 && scale != null) {
            int localPrecision = precision! - scale!;
            String allowedScale = scale! > 0 ? r"\d{0," + scale!.toString() + r"}" : "0";
            RegExp regExp = RegExp(r"^(\d{0," + localPrecision.toString() + r"}|0)(\." + allowedScale + r")?$");
            if (!regExp.hasMatch(number.toString() + endingZeroes)) {
              return newValue.copyWith(text: oldValue.text, selection: oldValue.selection);
            }
          }
        }
      } on FormatException {
        return oldValue;
      }
    }

    return newValue;
  }

  String getFormattedString(dynamic value) {
    if (value != null) {
      if (value is int || value is double) {
        return numberFormatter.format(value);
      } else if (value is String) {
        try {
          num numValue = numberFormatter.parse(value);
          return numberFormatter.format(numValue);
        } catch (_) {}

        return value;
      }
    }
    return "";
  }

  num? convertToNumber(dynamic pValue) {
    num? number;
    if (pValue is String) {
      if (pValue.isEmpty) return null;
      // Append zeroes to allow the user to enter a comma only
      if (pValue.endsWith(numberFormatter.symbols.DECIMAL_SEP)) {
        pValue += "0";
      }
      number = numberFormatter.parse("0$pValue");
    }
    return number;
  }

  TextInputType getKeyboardType() {
    return TextInputType.numberWithOptions(decimal: scale != 0, signed: signed);
  }
}
