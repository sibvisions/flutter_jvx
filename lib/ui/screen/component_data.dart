import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/new_bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/data/fetch_data.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';


class ComponentData {
  String dataProvider;
  bool isFetching = false;

  JVxData _data;
  JVxMetaData metaData;

  List<VoidCallback> _onDataChanged = [];
  List<VoidCallback> _onMetaDataChanged = [];

  ComponentData(this.dataProvider);


  void updateData(JVxData pData) {
    if (_data==null || _data.isAllFetched)
      _data = pData;
    else {
      _data.records.addAll(pData.records);
      _data.selectedRow = pData.selectedRow;
      _data.isAllFetched = pData.isAllFetched;
    }

    if (_data.selectedRow==null)
      _data.selectedRow = 0;

    isFetching = false;
    _onDataChanged.forEach((d) => d);
  }

  void updateMetaData(JVxMetaData pMetaData) {
    this.metaData = pMetaData;
    _onMetaDataChanged.forEach((d) => d);
  }

  dynamic getColumnData(BuildContext context, String columnName) {
    if (isFetching==false && (_data==null || 
      (_data.selectedRow >= _data.records.length && !_data.isAllFetched))) {
      this._fetchData(context);
    } 
    
    if (_data!=null && _data.selectedRow < _data.records.length) {
      return _getColumnValue(columnName);
    }

    return "";
  }

  JVxData getData(BuildContext context) {
    if (isFetching==false && (_data==null || !_data.isAllFetched)) {
      this._fetchData(context);
    }
      
    return _data;
  }

  void _fetchData(BuildContext context) {
      this.isFetching = true;
      FetchData fetch = FetchData(dataProvider);

      if (_data!=null && !_data.isAllFetched) {
        fetch.fromRow = _data.records.length;
        fetch.rowCount = 100;
      }

      BlocProvider.of<ApiBloc>(context).dispatch(fetch);
  }

  dynamic _getColumnValue(String columnName) {
    int columnIndex = _getColumnIndex(columnName);
    if (columnIndex!=null && _data.selectedRow>=0 && _data.selectedRow < _data.records.length) {
      return _data.records[_data.selectedRow][columnIndex];
    }

    return "";
  }

  int _getColumnIndex(String columnName) {
    return _data?.columnNames?.indexWhere((c) => c == columnName);
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