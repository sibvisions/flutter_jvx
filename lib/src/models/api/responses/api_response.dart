class ApiResponse{
  String name;

  ApiResponse.fromJson(Map<String, dynamic> json) :
    name = json[_PApiResponse.name];
}

class _PApiResponse {
  static const name = "name";
}