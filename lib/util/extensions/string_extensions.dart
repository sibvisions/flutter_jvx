extension StringExtension on String {
  /// Returns `true` if the string equals 'true', returns `false` if the string equals 'false' otherwise throws an exception.
  bool parseBool() {
    if (toLowerCase() == "true") {
      return true;
    } else if (toLowerCase() == "false") {
      return false;
    }

    throw "'$this' is not a boolean.";
  }

  /// Returns `true` if the string equals 'true', returns `false` if the string equals 'false' otherwise returns [pDefault].
  bool parseBoolDefault(bool pDefault) {
    try {
      return parseBool();
    } catch (_) {
      return pDefault;
    }
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String firstCharLower() {
    return "${this[0].toLowerCase()}${substring(1)}";
  }
}
