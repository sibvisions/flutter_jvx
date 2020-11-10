import '../request.dart';

class TabClose extends Request {
  final String componentId;
  final int index;

  TabClose({this.componentId, this.index, String clientId})
      : super(RequestType.TAB_CLOSE, clientId);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'componentId': componentId,
        'index': index,
      };
}
