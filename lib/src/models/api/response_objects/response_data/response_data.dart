import 'package:flutterclient/src/models/api/response_objects/response_data/screen_generic_response_object.dart';

import 'data/data_book.dart';
import 'data/dataprovider_changed.dart';
import 'meta_data/data_book_meta_data.dart';

class ResponseData {
  ScreenGenericResponseObject? screenGeneric;
  List<DataBook> dataBooks = <DataBook>[];
  List<DataBookMetaData> dataBookMetaData = <DataBookMetaData>[];
  List<DataproviderChanged> dataproviderChanged = <DataproviderChanged>[];
}
