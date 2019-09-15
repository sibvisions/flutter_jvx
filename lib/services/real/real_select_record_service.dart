import 'package:jvx_mobile_v3/model/data/data/select_record_resp.dart';
import 'package:jvx_mobile_v3/model/data/select_record.dart';
import 'package:jvx_mobile_v3/model/press_button/press_button_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_select_record_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';

class SelectRecordService extends NetworkService implements ISelectRecordService {
  static const _kSelectRecordUrl = '/api/dal/selectRecord';

  SelectRecordService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<SelectRecordResponse>> fetchSelectRecord(SelectRecord selectRecord) async {
    var result = await rest.postAsync(_kSelectRecordUrl, selectRecord.toJson());

    if (result.mappedResult != null) {
      var res = SelectRecordResponse.fromJson(result.mappedResult);
      return new NetworkServiceResponse(
        content: res,
        success: result.networkServiceResponse.success
      );
    }
    return new NetworkServiceResponse(
      success: result.networkServiceResponse.success,
      message: result.networkServiceResponse.message
    );
  }
}