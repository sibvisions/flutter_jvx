import 'package:flutter_client/src/model/api/response/dal_meta_data_response.dart';
import 'package:flutter_client/src/model/command/data/data_command.dart';

/// Command to save a [DalMetaDataResponse]
class SaveMetaDataCommand extends DataCommand {

  /// Metadata sent from server
  final DalMetaDataResponse response;

  SaveMetaDataCommand({
    required this.response,
    required String reason
  }) : super(reason: reason);


  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}