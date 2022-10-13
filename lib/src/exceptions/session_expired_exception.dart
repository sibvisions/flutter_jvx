class SessionExpiredException implements Exception {
  final int statusCode;

  SessionExpiredException(this.statusCode);
}
