import '../../../jvx_flutterclient.dart';

class TabClose extends Request {
  final String componentId;
  final int index;

  TabClose({this.componentId, this.index, String clientId})
      : super(clientId: clientId, requestType: RequestType.TAB_CLOSE);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'componentId': componentId,
        'index': index,
      };
}
