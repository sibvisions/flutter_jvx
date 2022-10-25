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
        num? number = convertToNumber(newString);
        if (number != null) {
          if (precision != null && precision! > 0 && scale != null) {
            int localPrecision = precision! - scale!;
            String allowedScale = scale! > 0 ? r"\d{0," + scale!.toString() + r"}" : "0";
            RegExp regExp = RegExp(r"^(\d{0," + localPrecision.toString() + r"}|0)(\." + allowedScale + r")?$");
            if (!regExp.hasMatch(number.toString())) {
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
      if (value is String) {
        return value;
      } else if (value is int || value is double) {
        return numberFormatter.format(value);
      }
    }
    return "";
  }

  num? convertToNumber(dynamic pValue) {
    num? number;
    if (pValue is String) {
      if (pValue.isEmpty) return null;
      // Append zeroes to allow the user to enter a comma only
      number = numberFormatter.parse("0${pValue}0");
    }
    return number;
  }

  TextInputType getKeyboardType() {
    return TextInputType.numberWithOptions(decimal: scale != 0, signed: signed);
  }
}
