import '../request.dart';

class Loading extends Request {
  Loading({RequestType requestType = RequestType.LOADING, String clientId})
      : super(requestType, clientId);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }
}
