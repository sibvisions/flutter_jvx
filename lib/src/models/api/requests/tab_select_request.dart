import '../request.dart';

class TabSelectRequest extends Request {
  final String componentId;
  final int index;

  @override
  String get debugInfo =>
      'clientId: $clientId, componentId: $componentId, index: $index';

  TabSelectRequest(
      {required this.componentId,
      required this.index,
      required String clientId,
      bool reload = false})
      : super(clientId: clientId, reload: reload);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'componentId': componentId,
        'index': index,
        ...super.toJson()
      };
}
