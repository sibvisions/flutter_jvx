import '../../../jvx_flutterclient.dart';

class TabSelect extends Request {
  final String componentId;
  final int index;

  TabSelect({this.componentId, this.index, String clientId})
      : super(clientId: clientId, requestType: RequestType.TAB_SELECT);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'componentId': componentId,
        'index': index,
      };
}
