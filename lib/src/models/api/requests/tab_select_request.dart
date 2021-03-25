import '../request.dart';

class TabSelectRequest extends Request {
  final String componentId;
  final int index;

  TabSelectRequest(
      {required this.componentId,
      required this.index,
      required String clientId,
      String? debugInfo,
      bool reload = false})
      : super(clientId: clientId, debugInfo: debugInfo, reload: reload);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'componentId': componentId,
        'index': index,
        ...super.toJson()
      };
}
