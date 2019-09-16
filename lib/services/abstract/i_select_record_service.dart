import 'package:jvx_mobile_v3/model/data/data/select_record_resp.dart';
import 'package:jvx_mobile_v3/model/data/select_record.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

abstract class ISelectRecordService {
  Future<NetworkServiceResponse<SelectRecordResponse>> fetchSelectRecord(
    SelectRecord selectRecord
  );
}