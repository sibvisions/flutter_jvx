class Convertion {
  static convertToBool(String value) {
    if (value==null) {
      return false;
    }

    return value.toLowerCase() == 'true';
  }
}