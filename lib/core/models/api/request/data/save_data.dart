import '../../request.dart';

class SaveData extends Request {
  String dataProvider;

  SaveData(this.dataProvider, String clientId)
      : super(RequestType.DAL_SAVE, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'dataProvider': dataProvider,
      };
}
