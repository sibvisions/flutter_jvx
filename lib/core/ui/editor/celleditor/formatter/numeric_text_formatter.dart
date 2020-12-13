import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumericTextFormatter extends TextInputFormatter {
  String _numberFormat;
  String _locale;
  int precision;
  int length;
  int _scale;
  bool signed;
  NumberFormat numberFormatter;

  get scale => _scale;
  set scale(int newScale) {
    _scale = newScale;

    /// ToDo intl Number Formatter only supports only patterns with up to 16 digits
    if (this._numberFormat != null && scale != null) {
      this._numberFormat = _cutDigits(this._numberFormat, scale);
    }

    numberFormatter = NumberFormat(this._numberFormat, this._locale);
  }

  get numberFormat => _numberFormat;
  set numberFormat(String newFormat) {
    _numberFormat = newFormat;

    /// ToDo intl Number Formatter only supports only patterns with up to 16 digits
    if (this._numberFormat != null) {
      this._numberFormat = _cutDigits(this._numberFormat, 14);
    }

    numberFormatter = NumberFormat(this._numberFormat, this._locale);
  }

  get locale => _locale;
  set locale(String newLocale) {
    _locale = newLocale;
    numberFormatter = NumberFormat(this._numberFormat, this._locale);
  }

  NumericTextFormatter(
      [String numberFormat,
      String locale,
      this.precision,
      this.length,
      int scale,
      this.signed])
      : super() {
    this.numberFormat = numberFormat;
    this.locale = locale;
    this.scale = scale;
  }

  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length == 0) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      String newString = newValue.text;
      int textLengthChange = newValue.text.length - oldValue.text.length;

      /// ToDo intl Number Formatter only supports only patterns with up to 16 digits
      if (newString.length > 16) return newValue.copyWith(text: oldValue.text);

      bool addTrailingDecSep = false;
      if (newString.endsWith(".") || newString.endsWith(",")) {
        addTrailingDecSep = true;
        newString = newString.substring(0, newString.length - 1);
      }

      dynamic number = this.convertToNumber(newString);

      if (precision != null && scale != null) {
        String toMatch = number.toString();
        RegExp expression = new RegExp(r"^(?=(\D*\d\D*){0," +
            precision.toString() +
            r"}$)-?([0-9]+)?([\.,]?[0-9]{0," +
            scale.toString() +
            r"})?$");

        if (!expression.hasMatch(toMatch))
          return newValue.copyWith(text: oldValue.text);
      }

      newString = this.getFormattedString(number);

      if (addTrailingDecSep) newString += numberFormatter.symbols.DECIMAL_SEP;
      if (textLengthChange < 0 && newString.length >= oldValue.text.length) {
        TextSelection selection = oldValue.selection;
        return newValue.copyWith(
            text: newString,
            selection:
                TextSelection.collapsed(offset: selection.baseOffset + 1));
      } else if (textLengthChange > 0 &&
          newString.length <= oldValue.text.length) {
        TextSelection selection = oldValue.selection;
        return newValue.copyWith(
            text: newString,
            selection: TextSelection.collapsed(offset: selection.baseOffset));
      }
      return newValue.copyWith(text: newString);
    } else {
      return newValue;
    }
  }

  String getFormattedString(dynamic value) {
    if (value != null && (value is int || value is double)) {
      if (numberFormat != null && numberFormat.isNotEmpty) {
        return numberFormatter.format(value);
      }

      return value;
    }

    return "";
  }

  dynamic convertToNumber(dynamic pValue) {
    dynamic number;
    if (pValue is String && pValue != null) {
      number = numberFormatter.parse(pValue);

      if (scale <= 0 && (number is double)) {
        number = int.parse(number.truncate().toString());
      }
    }

    return number;
  }

  TextInputType getKeyboardType() {
    if (this._numberFormat != null && this._numberFormat.isNotEmpty) {
      if (!this.numberFormat.contains(".")) return TextInputType.number;

      if (this.scale <= 0) return TextInputType.number;
    }

    return TextInputType.numberWithOptions(decimal: true);
  }

  String _cutDigits(String formatString, int cutAt) {
    List<String> numberFormatParts = this._numberFormat.split(".");
    if (numberFormatParts.length > 1 && numberFormatParts[1].length > cutAt) {
      String newFormat = numberFormatParts[0] +
          "." +
          numberFormatParts[1].substring(0, cutAt < 0 ? 0 : cutAt);
      if (newFormat.endsWith("."))
        return newFormat.substring(0, newFormat.length - 1);
      return newFormat;
    }

    return formatString;
  }
}
