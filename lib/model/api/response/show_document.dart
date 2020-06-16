import '../../../model/api/response/response_object.dart';

class ShowDocument extends ResponseObject {
  String document;
  String bounds;
  String target;

  ShowDocument({this.document, this.bounds, this.target});

  ShowDocument.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    String url = json['url'];

    if (url!=null){
      List<String> urlParts = url.split(';');

      if(urlParts!=null) {
        if (urlParts.length>0) document = urlParts[0];
        if (urlParts.length>1) bounds = urlParts[1];
        if (urlParts.length>2) target = urlParts[2];
      }
    } 
    
  }
}