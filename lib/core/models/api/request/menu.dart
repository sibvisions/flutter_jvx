import '../request.dart';

class Menu extends Request {
  Menu(String clientId)
      : super(RequestType.MENU, clientId);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'clientId': this.clientId};
}