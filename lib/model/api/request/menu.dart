import 'package:jvx_flutterclient/model/api/request/request.dart';

class Menu extends Request {
  Menu(String clientId)
      : super(clientId: clientId, requestType: RequestType.MENU);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'clientId': this.clientId};
}
