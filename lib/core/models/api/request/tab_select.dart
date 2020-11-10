import '../request.dart';

class TabSelect extends Request {
  final String componentId;
  final int index;

  TabSelect({this.componentId, this.index, String clientId})
      : super(RequestType.TAB_SELECT, clientId);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'componentId': componentId,
        'index': index,
      };
}
