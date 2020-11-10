import 'data/data_book.dart';
import 'data/dataprovider_changed.dart';
import 'meta_data/data_book_meta_data.dart';
import 'screen_generic.dart';

class ResponseData {
  ScreenGeneric screenGeneric;
  List<DataBook> dataBooks = <DataBook>[];
  List<DataBookMetaData> dataBookMetaData = <DataBookMetaData>[];
  List<DataproviderChanged> dataproviderChanged = <DataproviderChanged>[];
}