class ApiException implements Exception {
  String message;
  String title;
  String details;
  String name;

  ApiException({this.title, this.details, this.name, this.message});
}