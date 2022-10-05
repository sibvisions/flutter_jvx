extension BoolParsing on String {
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
}
