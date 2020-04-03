import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/model/api/response/data/jvx_dataprovider_changed.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/data/fetch_data.dart';
import '../../model/api/request/data/filter_data.dart';
import '../../model/api/request/data/insert_record.dart';
import '../../model/api/request/data/save_data.dart';
import '../../model/api/request/data/set_values.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/data/jvx_data.dart';
import '../../model/api/request/data/select_record.dart';
import '../../model/api/response/meta_data/jvx_meta_data.dart';
import '../../model/filter.dart';


class ComponentData {
  String dataProvider;
  bool isFetchingMetaData = false;
  bool isFetching = false;

  JVxData data;
  JVxMetaData metaData;

  List<VoidCallback> _onDataChanged = [];
  List<VoidCallback> _onMetaDataChanged = [];
  List<ValueChanged<dynamic>> _onSelectedRowChanged = [];

  ComponentData(this.dataProvider);


  bool get deleteEnabled {
    if (metaData!=null && metaData.deleteEnabled!=null) return metaData.deleteEnabled;
    return false;
  }

  bool get updateEnabled {
    if (metaData!=null && metaData.updateEnabled!=null) return metaData.updateEnabled;
    return false;
  }

  bool get insertEnabled {
    if (metaData!=null && metaData.insertEnabled!=null) return metaData.insertEnabled;
    return false;
  }

  List<String> get primaryKeyColumns {
    if (metaData!=null && metaData.primaryKeyColumns!=null) return metaData.primaryKeyColumns;
    return null;
  }

  List<dynamic> primaryKeyColumnsForRow(int index) {
    if (metaData!=null && metaData.primaryKeyColumns!=null) return metaData.primaryKeyColumns;
    return null;
  }

  void updateData(JVxData pData, [bool overrideData = false]) {
    //if (data==null || data.isAllFetched || overrideData) {
    if (data==null || overrideData) {
      if (data!=null && pData!=null && data.selectedRow != pData.selectedRow) _onSelectedRowChanged.forEach((d) => d(pData.selectedRow));
      data = pData;
    } else if (data.isAllFetched){
      if (pData.records.length>0) {
        for (int i=pData.from;i<=pData.to;i++) {
          if ((i-pData.from) < data.records.length && i<this.data.records.length) {
            List<dynamic> record = pData.records[(i-pData.from)];
            String recordState = record[record.length-1];
            if (recordState=="I")
              this.data.records.insert((i-pData.from), pData.records[(i-pData.from)]);
            else if (recordState=="D")
              this.data.records.removeAt((i-pData.from));
            else
              this.data.records[i] = pData.records[(i-pData.from)];
          } else {
            this.data.records.add(pData.records[(i-pData.from)]);
          }
        }
      }
      data.isAllFetched = pData.isAllFetched;
      if (data.selectedRow != pData.selectedRow) _onSelectedRowChanged.forEach((d) => d(pData.selectedRow));
      data.selectedRow = pData.selectedRow;
    } else {
      data.records.addAll(pData.records);
      if (data.selectedRow != pData.selectedRow) _onSelectedRowChanged.forEach((d) => d(pData.selectedRow));
      data.selectedRow = pData.selectedRow;
      data.isAllFetched = pData.isAllFetched;
    }

    if (data.selectedRow==null)
      data.selectedRow = 0;

    isFetching = false;
    _onDataChanged.forEach((d) => d());
  }

  void updateDataProviderChanged(BuildContext context, JVxDataproviderChanged pDataproviderChanged) {
    _fetchData(context, pDataproviderChanged.reload, -1);
    if (data!=null)
      updateSelectedRow(pDataproviderChanged.selectedRow);
  }

  void updateSelectedRow(int selectedRow, [bool raiseSelectedRowChangeEvent = false]) {
    if (data!=null)
    { 
      if (data.selectedRow==null || data.selectedRow!=selectedRow) {
        data.selectedRow = selectedRow;
        if (raiseSelectedRowChangeEvent) _onSelectedRowChanged.forEach((d) => d(selectedRow));
        _onDataChanged.forEach((d) => d());
      }
    } else {
      print("ComponentData tries to update selectedRow, but data object was null! DataProvider: " + this.dataProvider);
    }
  }

  void updateMetaData(JVxMetaData pMetaData) {
    this.metaData = pMetaData;
    this.isFetchingMetaData = false;
    _onMetaDataChanged.forEach((d) => d());
  }

  dynamic getColumnData(BuildContext context, String columnName) {

    if (data!=null && data.selectedRow < data.records.length) {
      return _getColumnValue(columnName);
    } else {
      this._fetchData(context, null, -1);
    }

    return "";
  }

  JVxData getData(BuildContext context, int rowCountNeeded) {

    if (isFetching==false && (data==null || !data.isAllFetched)) {
      if (rowCountNeeded>=0 && data!=null && data.records != null && data.records.length>=rowCountNeeded) {
        return data;
      }
      if (!this.isFetching)
        this._fetchData(context, null, rowCountNeeded);
    }
      
    return data;
  }

  void selectRecord(BuildContext context, int index, [bool fetch = false]) {
    if (index < data.records.length) {
      SelectRecord select = SelectRecord(
        dataProvider, 
        Filter(columnNames: this.primaryKeyColumns, values: data.getRow(index, this.primaryKeyColumns)),
        index,
        RequestType.DAL_SELECT_RECORD);

      if (fetch!=null)
        select.fetch = fetch;

      //_data.selectedRow = index;
      //_onDataChanged.forEach((d) => d());
      BlocProvider.of<ApiBloc>(context).dispatch(select);
    } else {
      IndexError(index, data.records, "Select Record", "Select record failed. Index out of bounds!");
    }
  }

  void deleteRecord(BuildContext context, int index) {
    if (index < data.records.length) {
      SelectRecord select = SelectRecord(
        dataProvider, 
        Filter(columnNames: this.primaryKeyColumns, values: data.getRow(index, this.primaryKeyColumns)),
        index,
        RequestType.DAL_DELETE);

      BlocProvider.of<ApiBloc>(context).dispatch(select);
    } else {
      IndexError(index, data.records, "Delete Record", "Delete record failed. Index out of bounds!");
    }
  }

  void insertRecord(BuildContext context) {
    if (insertEnabled) {
      InsertRecord insert = InsertRecord(this.dataProvider);

      BlocProvider.of<ApiBloc>(context).dispatch(insert);
    }
  }

  void saveData(BuildContext context) {
    SaveData save = SaveData(this.dataProvider);
    BlocProvider.of<ApiBloc>(context).dispatch(save);
  }

  void filterData(BuildContext context, String value, String editorComponentId) {
    FilterData filter = FilterData(dataProvider, value, editorComponentId, null, 0, 100);
    filter.reload = true;
    BlocProvider.of<ApiBloc>(context).dispatch(filter);
  }

  void setValues(BuildContext context, List<dynamic> values, [List<dynamic> columnNames, Filter filter]) {

    SetValues setValues = SetValues(this.dataProvider, data?.columnNames, values);

    if (columnNames!=null) {
      columnNames.asMap().forEach((i,f) {
        if (i< values.length) this._setColumnValue(f, values[i]);
      });
      setValues.columnNames = columnNames;
    }

    if (filter!=null)
      setValues.filter = filter;

    BlocProvider.of<ApiBloc>(context).dispatch(setValues);
  }

  void _fetchData(BuildContext context, int reload, int rowCountNeeded) {
      this.isFetching = true;
      FetchData fetch = FetchData(dataProvider);

      if (reload != null && reload>=0) {
        fetch.fromRow = reload;
        fetch.rowCount = 1;
      } else if (reload != null && reload==-1 && rowCountNeeded!=-1) {
        fetch.fromRow = 0;
        fetch.rowCount = rowCountNeeded - data.records.length;
      } else if (data!=null && !data.isAllFetched && rowCountNeeded!=-1) {
        fetch.fromRow = data.records.length;
        fetch.rowCount = rowCountNeeded - data.records.length;
      }

      fetch.reload = (reload==-1);
      
      if (this.metaData==null) {
        fetch.includeMetaData = true;
        isFetchingMetaData = true;
      }

      BlocProvider.of<ApiBloc>(context).dispatch(fetch);
  }

  dynamic _getColumnValue(String columnName) {
    int columnIndex = _getColumnIndex(columnName);
    if (columnIndex!=null && data.selectedRow>=0 && data.selectedRow < data.records.length) {
      dynamic value = data.records[data.selectedRow][columnIndex];
      if (value is String)
        return value;
      else 
        return value;
    }

    return "";
  }

  void _setColumnValue(String columnName, dynamic value) {
    int columnIndex = _getColumnIndex(columnName);
    if (columnIndex!=null && data.selectedRow>=0 && data.selectedRow < data.records.length) {
      data.records[data.selectedRow][columnIndex] = value;
    }
  }

  int _getColumnIndex(String columnName) {
    return data?.columnNames?.indexWhere((c) => c == columnName);
  }

  void registerSelectedRowChanged(ValueChanged<dynamic> callback) {
    _onSelectedRowChanged.add(callback);
  }

  void unregisterSelectedRowChanged(ValueChanged<dynamic> callback) {
    _onSelectedRowChanged.remove(callback);
  }

  void registerDataChanged(VoidCallback callback) {
    _onDataChanged.add(callback);
  }

  void unregisterDataChanged(VoidCallback callback) {
    _onDataChanged.remove(callback);
  }

  void registerMetaDataChanged(VoidCallback callback) {
    _onMetaDataChanged.add(callback);
  }

  void unregisterMetaDataChanged(VoidCallback callback) {
    _onMetaDataChanged.remove(callback);
  }
}