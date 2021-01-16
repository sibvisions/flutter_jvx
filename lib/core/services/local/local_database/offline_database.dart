import 'dart:io';
import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/cell_editor_properties.dart';
import '../../../models/api/request.dart';
import '../../../models/api/request/data/fetch_data.dart';
import '../../../models/api/request/data/insert_record.dart';
import '../../../models/api/request/data/select_record.dart';
import '../../../models/api/request/data/set_values.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/data/data_book.dart';
import '../../../models/api/response/meta_data/data_book_meta_data.dart';
import '../../../models/api/response/response_data.dart';
import '../../../ui/screen/so_component_data.dart';
import 'local_database.dart';

const String CREATE_TABLE_COLUMNS_SEPERATOR = ", ";
const String CREATE_TABLE_COLUMNS_OLD_SUFFIX = "_old";
const String CREATE_TABLE_COLUMNS_NEW_SUFFIX = "_new";
const String CREATE_TABLE_NAME_PREFIX = "off_";

const String INSERT_INTO_DATA_SEPERATOR = ", ";
const String UPDATE_DATA_SEPERATOR = ", ";

const String OFFLINE_COLUMNS_PRIMARY_KEY = "off_primaryKey";
const String OFFLINE_COLUMNS_MASTER_KEY = "off_masterKey";
const String OFFLINE_COLUMNS_STATE = "off_state";
const String OFFLINE_COLUMNS_CREATED = "off_created";
const String OFFLINE_COLUMNS_CHANGED = "off_changed";

const String OFFLINE_ROW_STATE_EDITED = "U";
const String OFFLINE_ROW_STATE_INSERTED = "I";
const String OFFLINE_ROW_STATE_DELETED = "D";

class OfflineDatabase extends LocalDatabase {
  Future<void> importComponentList(List<SoComponentData> componentData) async {
    Future.forEach(componentData, (element) async {
      await importComponent(element);
    });
  }

  Future<void> importComponent(SoComponentData componentData) async {
    if (componentData != null &&
        componentData.data != null &&
        componentData.metaData != null) {
      String tableName = _formatTableName(componentData.dataProvider);
      if (await tableExists(tableName)) {
        await this.dropTable(tableName);
      }

      await createTableWithMetaData(componentData.metaData);
      await importRows(componentData.data);
    }
  }

  Future<void> createTableWithMetaData(DataBookMetaData metaData) async {
    if (metaData != null &&
        metaData.columns != null &&
        metaData.columns.length > 0) {
      String tablename = _formatTableName(metaData.dataProvider);
      if (!await tableExists(tablename)) {
        String columns = "";
        metaData.columns.forEach((column) {
          columns += _formatColumnForCreateTable(
              column.name, _getDataType(column.cellEditor));
        });

        if (columns.length > 0) {
          columns += _getOfflineColumns();
          if (columns.endsWith(CREATE_TABLE_COLUMNS_SEPERATOR))
            columns = columns.substring(
                0, columns.length - CREATE_TABLE_COLUMNS_SEPERATOR.length);

          await createTable(tablename, columns);
        }
      }
    }
  }

  Future<bool> importRows(DataBook data) async {
    int failedInsertCount = 0;

    if (data != null &&
        data.dataProvider != null &&
        data.records != null &&
        data.records.length > 0 &&
        data.columnNames != null) {
      String tableName = _formatTableName(data.dataProvider);

      if (await tableExists(tableName)) {
        await Future.forEach(data.records, (element) async {
          String columnString = _getInsertColumnList(data.columnNames);
          String valueString = _getInsertValueList(element);

          if (!await this.insert(tableName, columnString, valueString)) {
            failedInsertCount++;
          }
        });

        if (failedInsertCount > 0) {
          return false;
        } else {
          return true;
        }
      }
    }

    return false;
  }

  Future<List<List<dynamic>>> getSyncData(String dataProvider) async {
    if (dataProvider != null) {
      String tableName = _formatTableName(dataProvider);
      String where = "[$OFFLINE_COLUMNS_STATE]<>''";
      String orderBy = "[$OFFLINE_COLUMNS_CHANGED]";

      List<Map<String, dynamic>> result =
          await this.selectRows(tableName, where, orderBy);

      List<List<dynamic>> records = new List<List<dynamic>>();

      result.forEach((element) {
        records.add(_removeSpecialColumns(element).values.toList());
      });

      return records;
    }
  }

  Future<bool> cleanupDatabase() async {
    await this.closeDatabase();
    try {
      File file = File(this.path);
      await file.delete();
    } catch (error) {
      print(error);
    }
  }

  Future<Response> fetchData(FetchData request) async {
    if (request != null && request.dataProvider != null) {
      String tableName = _formatTableName(request.dataProvider);
      String orderBy = "[$OFFLINE_COLUMNS_PRIMARY_KEY]";
      String limit = "";
      if (request.fromRow != null && request.fromRow >= 0) {
        limit = request.fromRow.toString();
        if (request.rowCount >= 0) limit = ", " + request.rowCount.toString();
      } else if (request.rowCount != null && request.rowCount >= 0) {
        limit = request.rowCount.toString();
      }

      String where = "[$OFFLINE_COLUMNS_STATE]<>'$OFFLINE_ROW_STATE_DELETED'";

      List<Map<String, dynamic>> result =
          await this.selectRows(tableName, where, orderBy, limit);

      List<List<dynamic>> records = new List<List<dynamic>>();

      result.forEach((element) {
        records.add(_removeSpecialColumns(element).values.toList());
      });

      Response response = new Response();
      ResponseData data = new ResponseData();
      DataBook dataBook = new DataBook(
        dataProvider: request.dataProvider,
        records: records,
      );

      if (request.fromRow != null)
        dataBook.from = request.fromRow;
      else {
        dataBook.from = 0;
        dataBook.isAllFetched = true;
      }
      dataBook.to = records.length + dataBook.from;

      data.dataBooks = [dataBook];
      response.responseData = data;
      return response;
    }

    return null;
  }

  Future<Response> setValues(SetValues request) async {
    if (request != null &&
        request.columnNames != null &&
        request.values != null &&
        request.columnNames.length > 0 &&
        request.columnNames.length == request.values.length &&
        request.offlineSelectedRow != null &&
        request.offlineSelectedRow >= 0) {
      String tableName = _formatTableName(request.dataProvider);

      if (await tableExists(tableName)) {
        String sqlSet = "";
        Map<String, dynamic> record =
            await _getRowWithIndex(tableName, request.offlineSelectedRow);
        dynamic offlinePrimaryKey = await this._getOfflinePrimaryKey(record);

        for (int i = 0; i < request.columnNames.length; i++) {
          dynamic value = request.values[i];
          String columnName = request.columnNames[i];
          if (value == null)
            sqlSet =
                "$sqlSet[$columnName$CREATE_TABLE_COLUMNS_NEW_SUFFIX]=NULL$UPDATE_DATA_SEPERATOR";
          else
            sqlSet =
                "$sqlSet[$columnName$CREATE_TABLE_COLUMNS_NEW_SUFFIX]='${value.toString()}'$UPDATE_DATA_SEPERATOR";
        }

        if (sqlSet.length > 0) {
          String rowState = await this._getRowState(record);
          if (rowState != OFFLINE_ROW_STATE_INSERTED &&
              rowState != OFFLINE_ROW_STATE_DELETED) {
            sqlSet =
                "$sqlSet[$OFFLINE_COLUMNS_STATE]='$OFFLINE_ROW_STATE_EDITED'";
            sqlSet = "$sqlSet[$OFFLINE_COLUMNS_CHANGED]=datetime('now')";
          }
          String where =
              "$OFFLINE_COLUMNS_PRIMARY_KEY='${offlinePrimaryKey.toString()}'";
          if (await this.update(tableName, sqlSet, where)) {
            Map<String, dynamic> row = await _getRowWithOfflinePrimaryKey(
                tableName, offlinePrimaryKey);
            List<dynamic> records = row.values.toList();
            Response response = new Response();
            ResponseData data = new ResponseData();
            DataBook dataBook = new DataBook(
              dataProvider: request.dataProvider,
              selectedRow: request.offlineSelectedRow,
              records: records,
            );

            dataBook.from = request.offlineSelectedRow;
            dataBook.to = request.offlineSelectedRow;

            data.dataBooks = [dataBook];
            response.responseData = data;
            return response;
          }
        }
      }
    }
    return null;
  }

  Future<Response> selectRecord(SelectRecord request) async {
    if (request != null) {
      Response response = new Response();
      ResponseData data = new ResponseData();
      DataBook dataBook = new DataBook(
        dataProvider: request.dataProvider,
        selectedRow: request.selectedRow,
      );

      if (request.selectedRow >= 0) {
        String tableName = _formatTableName(request.dataProvider);

        Map<String, dynamic> record =
            await _getRowWithIndex(tableName, request.selectedRow);
        dataBook.records = _removeSpecialColumns(record).values.toList();
        dataBook.from = request.selectedRow;
        dataBook.to = request.selectedRow;
      }

      data.dataBooks = [dataBook];
      response.responseData = data;
      return response;
    }
    return null;
  }

  Future<Response> deleteRecord(SelectRecord request) async {
    if (request != null) {
      String tableName = _formatTableName(request.dataProvider);
      if (await tableExists(tableName)) {
        Map<String, dynamic> record =
            await _getRowWithIndex(tableName, request.selectedRow);
        dynamic offlinePrimaryKey = await this._getOfflinePrimaryKey(record);
        String rowState = await this._getRowState(record);
        String where =
            "$OFFLINE_COLUMNS_PRIMARY_KEY='${offlinePrimaryKey.toString()}'";

        // Delete locally if inserted before
        if (rowState == OFFLINE_ROW_STATE_INSERTED) {
          if (await this.delete(tableName, where)) {
            FetchData fetch = FetchData(request.dataProvider, request.clientId);
            return await this.fetchData(fetch);
          }
        } else {
          String sqlSet =
              "[$OFFLINE_COLUMNS_STATE] = '$OFFLINE_ROW_STATE_DELETED'$INSERT_INTO_DATA_SEPERATOR[$OFFLINE_COLUMNS_CHANGED] = datetime('now')";
          if (await this.update(tableName, sqlSet, where)) {
            FetchData fetch = FetchData(request.dataProvider, request.clientId);
            return await this.fetchData(fetch);
          }
        }
      }
    }
    return null;
  }

  Future<Response> insertRecord(InsertRecord request) async {
    if (request != null && request.dataProvider != null) {
      String tableName = _formatTableName(request.dataProvider);
      int count = await this.rowCount(tableName);
      String columnString =
          "[$OFFLINE_COLUMNS_STATE]$INSERT_INTO_DATA_SEPERATOR[$OFFLINE_COLUMNS_CHANGED]";
      String valueString =
          "'$OFFLINE_ROW_STATE_INSERTED'${INSERT_INTO_DATA_SEPERATOR}datetime('now')";
      if (await insert(tableName, columnString, valueString)) {
        Response response = new Response();
        ResponseData data = new ResponseData();
        DataBook dataBook = new DataBook(
          dataProvider: request.dataProvider,
          selectedRow: count,
        );
        Map<String, dynamic> record = await _getRowWithIndex(tableName, count);
        dataBook.records = _removeSpecialColumns(record).values.toList();

        dataBook.from = count;
        dataBook.to = count;

        data.dataBooks = [dataBook];
        response.responseData = data;
        return response;
      }
    }

    return null;
  }

  Future<Response> request(Request request) async {
    if (request != null) {
      if (request is FetchData) {
        return await fetchData(request);
      } else if (request is SetValues) {
        return await this.setValues(request);
      } else if (request is InsertRecord) {
        return await this.insertRecord(request);
      } else if (request is SelectRecord) {
        if (request.requestType == RequestType.DAL_SELECT_RECORD) {
          return await this.selectRecord(request);
        } else if (request.requestType == RequestType.DAL_DELETE) {
          return await this.deleteRecord(request);
        }
      }
    }

    return null;
  }

  Future<Map<String, dynamic>> _getRowWithOfflinePrimaryKey(
      String tableName, dynamic offlinePrimaryKey) async {
    String where =
        "[$OFFLINE_COLUMNS_PRIMARY_KEY]='${offlinePrimaryKey.toString()}'";
    List<Map<String, dynamic>> result = await this.selectRows(tableName, where);

    if (result.length > 0) {
      return _removeSpecialColumns(result[0]);
    }
    return null;
  }

  Future<Map<String, dynamic>> _getRowWithIndex(
      String tableName, int index) async {
    String orderBy = "[$OFFLINE_COLUMNS_PRIMARY_KEY]";
    String where = "[$OFFLINE_COLUMNS_STATE]<>'$OFFLINE_ROW_STATE_DELETED'";
    List<Map<String, dynamic>> result =
        await this.selectRows(tableName, where, orderBy, "$index, 1");

    if (result != null && result.length > 0) {
      return result[0];
    }

    return null;
  }

  Map<String, dynamic> _removeSpecialColumns(Map<String, dynamic> row) {
    Map<String, dynamic> cleanRows = new Map<String, dynamic>();

    row.forEach((columnName, value) {
      if (columnName.endsWith(CREATE_TABLE_COLUMNS_NEW_SUFFIX)) {
        String newColumnName = columnName.substring(
            0, columnName.length - CREATE_TABLE_COLUMNS_NEW_SUFFIX.length);
        cleanRows[newColumnName] = value;
      } else if (columnName == OFFLINE_COLUMNS_STATE) {
        cleanRows[OFFLINE_COLUMNS_STATE] = value;
      }
    });

    return cleanRows;
  }

  Future<dynamic> _getOfflinePrimaryKey(Map<String, dynamic> result) async {
    if (result != null && result.containsKey(OFFLINE_COLUMNS_PRIMARY_KEY)) {
      return result[OFFLINE_COLUMNS_PRIMARY_KEY];
    }

    return null;
  }

  Future<String> _getRowState(Map<String, dynamic> result) async {
    if (result != null && result.containsKey(OFFLINE_COLUMNS_STATE)) {
      return result[OFFLINE_COLUMNS_STATE].toString();
    }

    return null;
  }

  String _getInsertValueList(List<dynamic> row) {
    String insertString = "";
    if (row != null && row.length > 0) {
      // remove metaData column
      row.removeLast();

      row.forEach((item) {
        if (item != null) {
          dynamic value = item;
          if (value is String) {
            value = LocalDatabase.escapeStringForSqlLite(item);
          }
          insertString =
              "$insertString'$value'$INSERT_INTO_DATA_SEPERATOR'$value'$INSERT_INTO_DATA_SEPERATOR";
        } else {
          insertString =
              "${insertString}NULL${INSERT_INTO_DATA_SEPERATOR}NULL$INSERT_INTO_DATA_SEPERATOR";
        }
      });

      insertString =
          "${insertString}datetime('now')$INSERT_INTO_DATA_SEPERATOR";

      insertString = insertString.substring(
          0, insertString.length - INSERT_INTO_DATA_SEPERATOR.length);
    }

    return insertString;
  }

  String _getInsertColumnList(List<dynamic> columnNames) {
    String columnList = "";

    columnNames.forEach((item) {
      columnList =
          "$columnList[$item$CREATE_TABLE_COLUMNS_OLD_SUFFIX]$INSERT_INTO_DATA_SEPERATOR[$item$CREATE_TABLE_COLUMNS_NEW_SUFFIX]$INSERT_INTO_DATA_SEPERATOR";
    });

    columnList =
        "$columnList$OFFLINE_COLUMNS_CREATED$INSERT_INTO_DATA_SEPERATOR";

    columnList = columnList.substring(
        0, columnList.length - INSERT_INTO_DATA_SEPERATOR.length);
    return columnList;
  }

  String _formatColumnForCreateTable(String columnName, String type) {
    return "[$columnName$CREATE_TABLE_COLUMNS_OLD_SUFFIX] $type $CREATE_TABLE_COLUMNS_SEPERATOR" +
        "[$columnName$CREATE_TABLE_COLUMNS_NEW_SUFFIX] $type $CREATE_TABLE_COLUMNS_SEPERATOR";
  }

  String _formatTableName(String tableName) {
    if (tableName != null) {
      tableName = tableName.replaceAll(" ", "_");
      tableName = tableName.replaceAll("#", "_");
      tableName = tableName.replaceAll("!", "_");
      tableName = tableName.replaceAll("@", "_");
      tableName = tableName.replaceAll("'", "_");
      tableName = tableName.replaceAll("☺", "_");
      tableName = tableName.replaceAll("\\", "_");
      tableName = tableName.replaceAll("\"", "_");
      tableName = tableName.replaceAll("/", "_");

      tableName = CREATE_TABLE_NAME_PREFIX + tableName;
    }

    return tableName;
  }

  String _getOfflineColumns() {
    return "$OFFLINE_COLUMNS_PRIMARY_KEY INTEGER PRIMARY KEY$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_MASTER_KEY INTEGER$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_STATE TEXT DEFAULT ''$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_CREATED INTEGER$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_CHANGED INTEGER$CREATE_TABLE_COLUMNS_SEPERATOR";
  }

  String _getDataType(CellEditor editor) {
    switch (editor.className) {
      case 'TextCellEditor':
        return "TEXT";
        break;
      case 'NumberCellEditor':
        if (editor.getProperty<int>(CellEditorProperty.SCALE) == 0)
          return "INTEGER";
        else
          return "NUMERIC";
        break;
      case 'DateCellEditor':
        return 'NUMERIC';
        break;
      case 'ImageCellEditor':
        return 'BLOB';
        break;
      case 'ChoiceCellEditor':
        return 'TEXT';
        break;
      case 'LinkedCellEditor':
        return 'TEXT';
        break;
      case 'CheckBoxCellEditor':
        return 'NUMERIC';
        break;
    }

    return 'TEXT';
  }
}
