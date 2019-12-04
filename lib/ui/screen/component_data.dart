import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/data/fetch_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/filter_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/insert_record.dart';
import 'package:jvx_mobile_v3/model/api/request/data/save_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/set_values.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/select_record.dart';
import 'package:jvx_mobile_v3/model/api/response/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/filter.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';


class ComponentData {
  String dataProvider;
  bool isFetching = false;

  JVxData data;
  JVxMetaData metaData;

  List<VoidCallback> _onDataChanged = [];
  List<VoidCallback> _onMetaDataChanged = [];

  ValueChanged<Request> addToRequestQueue;

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
    if (data==null || data.isAllFetched || overrideData) {
      data = pData;
    } else {
      data.records.addAll(pData.records);
      data.selectedRow = pData.selectedRow;
      data.isAllFetched = pData.isAllFetched;
    }

    if (data.selectedRow==null)
      data.selectedRow = 0;

    isFetching = false;
    _onDataChanged.forEach((d) => d());
  }

  void updateSelectedRow(int selectedRow) {
    if (data.selectedRow!=selectedRow) {
      data.selectedRow = selectedRow;
      _onDataChanged.forEach((d) => d());
    }
  }

  void updateMetaData(JVxMetaData pMetaData) {
    this.metaData = pMetaData;
    _onMetaDataChanged.forEach((d) => d());
  }

  dynamic getColumnData(BuildContext context, String columnName, int reload) {
    if (isFetching==false && (data==null || reload==-1 ||
      (data.selectedRow >= data.records.length && !data.isAllFetched))) {
      if (data==null || data.selectedRow==null || data.selectedRow<0) {
        this._fetchData(context, reload, 0);
      } else {
        this._fetchData(context, reload, data.selectedRow);
      }
    } 
    
    if (data!=null && data.selectedRow < data.records.length) {
      return _getColumnValue(columnName);
    }

    return "";
  }

  JVxData getData(BuildContext context, int reload, int rowCountNeeded) {

    if (reload==-1 || (isFetching==false && (data==null || !data.isAllFetched))) {
      if (reload!=-1 && rowCountNeeded>=0 && data!=null && data.records != null && data.records.length>=rowCountNeeded) {
        return data;
      }
      
      this._fetchData(context, reload, rowCountNeeded);
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

      addToRequestQueue(select);
      //_data.selectedRow = index;
      //_onDataChanged.forEach((d) => d());
      //BlocProvider.of<ApiBloc>(context).dispatch(select);
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

      addToRequestQueue(select);
      //_data.selectedRow = index;
      //_onDataChanged.forEach((d) => d());
      //BlocProvider.of<ApiBloc>(context).dispatch(select);
    } else {
      IndexError(index, data.records, "Delete Record", "Delete record failed. Index out of bounds!");
    }
  }

  void insertRecord(BuildContext context) {
    if (insertEnabled) {
      InsertRecord insert = InsertRecord(this.dataProvider);

      addToRequestQueue(insert);
    }
  }

  void saveData(BuildContext context) {
    SaveData save = SaveData(this.dataProvider);
    addToRequestQueue(save);
  }

  void filterData(BuildContext context, String value, String editorComponentId) {
    FilterData filter = FilterData(dataProvider, value, editorComponentId, null, 0, 100);
    addToRequestQueue(filter);
  }

  void setValues(BuildContext context, List<dynamic> values, [List<dynamic> columnNames, Filter filter]) {
    SetValues setValues = SetValues(this.dataProvider, data?.columnNames, values);

    if (columnNames!=null)
      setValues.columnNames = columnNames;

    if (filter!=null)
      setValues.filter = filter;

    addToRequestQueue(setValues);
    //BlocProvider.of<ApiBloc>(context).dispatch(setValues);
  }

  void _fetchData(BuildContext context, int reload, int rowCountNeeded) {
      this.isFetching = true;
      FetchData fetch = FetchData(dataProvider);

      if (reload==-1 && rowCountNeeded!=-1) {
        fetch.fromRow = 0;
        fetch.rowCount = rowCountNeeded - data.records.length;
      } else if (data!=null && !data.isAllFetched && rowCountNeeded!=-1) {
        fetch.fromRow = data.records.length;
        fetch.rowCount = rowCountNeeded - data.records.length;
      }

      addToRequestQueue(fetch);
      //BlocProvider.of<ApiBloc>(context).dispatch(fetch);
  }

  dynamic _getColumnValue(String columnName) {
    int columnIndex = _getColumnIndex(columnName);
    if (columnIndex!=null && data.selectedRow>=0 && data.selectedRow < data.records.length) {
      dynamic value = data.records[data.selectedRow][columnIndex];
      if (value is String)
        return Properties.utf8convert(value);
      else 
        return value;
    }

    return "";
  }

  int _getColumnIndex(String columnName) {
    return data?.columnNames?.indexWhere((c) => c == columnName);
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