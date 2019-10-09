class ApiException implements Exception {
  String message = 'Api Exception. App will Restart';
  String title;
  String details;
  String name;

  ApiException({this.title, this.details, this.name});
}