import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data_data_provider.dart';

class JVxMetaDataCellEditor {
  int length;
  String contentType;
  JVxMetaDataDataProvider jVxDataProvider;
  String className;
  int scale;
  int precision;
  String numberFormat;
  bool signed;

  JVxMetaDataCellEditor({this.jVxDataProvider, this.className, this.length, this.scale, this.precision, this.numberFormat, this.signed, this.contentType});

  JVxMetaDataCellEditor.fromJson(Map<String, dynamic> json) {
    if (json['dataProvider'] != null)
      jVxDataProvider = JVxMetaDataDataProvider.fromJson(json['dataProvider']);
    className = json['className'];
    length = json['length'];
    contentType = json['contentType'];
    scale = json['scale'];
    precision = json['precision'];
    numberFormat = json['numberFormat'];
    signed = json['signed'];
  }
}