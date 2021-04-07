import '../request.dart';

class TabCloseRequest extends Request {
  final String componentId;
  final int index;

  TabCloseRequest(
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
