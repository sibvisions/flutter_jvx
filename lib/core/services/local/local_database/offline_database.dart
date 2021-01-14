import 'package:jvx_flutterclient/core/models/api/request.dart';
import 'package:jvx_flutterclient/core/models/api/request/data/fetch_data.dart';
import 'package:jvx_flutterclient/core/models/api/request/data/insert_record.dart';
import 'package:jvx_flutterclient/core/models/api/request/data/select_record.dart';
import 'package:jvx_flutterclient/core/models/api/request/data/set_values.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';
import 'package:jvx_flutterclient/core/models/api/response/data/data_book.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/cell_editor_properties.dart';
import '../../../models/api/response/meta_data/data_book_meta_data.dart';
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
const String OFFLINE_COLUMNS_SELECTED = "off_selected";
const String OFFLINE_COLUMNS_CREATED = "off_created";
const String OFFLINE_COLUMNS_CHANGED = "off_changed";

class OfflineDatabase extends LocalDatabase {
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
          String valueString = _getInsertValueList(element);
          String columnString = _getInsertColumnList(
              data.columnNames, CREATE_TABLE_COLUMNS_OLD_SUFFIX);

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

  Future<Response> setValues(SetValues request) async {
    if (request != null &&
        request.columnNames != null &&
        request.values != null &&
        request.columnNames.length > 0 &&
        request.columnNames.length == request.values.length) {
      String tableName = _formatTableName(request.dataProvider);

      if (await tableExists(tableName)) {
        String sqlSet = "";
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
        //await this.update(tableName, sqlSet, where);
      }
    }
  }

  Future<Response> selectRecord(SelectRecord request) async {
    if (request != null) {
      String tableName = _formatTableName(request.dataProvider);

      if (await tableExists(tableName)) {}
    }
    return null;
  }

  Future<void> deleteRecord() {}
  Future<void> insertRecord() {}

  Future<Response> request(Request request) {
    if (request != null) {
      if (request is FetchData) {
      } else if (request is SetValues) {
        this.setValues(request);
      } else if (request is InsertRecord) {
      } else if (request is SelectRecord) {
        if (request.requestType == RequestType.DAL_SELECT_RECORD) {
        } else if (request.requestType == RequestType.DAL_DELETE) {}
      }
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
          insertString = "$insertString'$value'$INSERT_INTO_DATA_SEPERATOR";
        } else {
          insertString = "${insertString}NULL$INSERT_INTO_DATA_SEPERATOR";
        }
      });

      insertString =
          "${insertString}datetime('now')$INSERT_INTO_DATA_SEPERATOR";

      insertString = insertString.substring(
          0, insertString.length - INSERT_INTO_DATA_SEPERATOR.length);
    }

    return insertString;
  }

  String _getInsertColumnList(List<dynamic> columnNames, String columnSuffix) {
    String columnList = "";

    columnNames.forEach((item) {
      String formatedColumnName =
          _formatColumnForInsert(item.toString(), columnSuffix);
      columnList = "$columnList$formatedColumnName$INSERT_INTO_DATA_SEPERATOR";
    });

    columnList =
        "$columnList$OFFLINE_COLUMNS_CREATED$INSERT_INTO_DATA_SEPERATOR";

    columnList = columnList.substring(
        0, columnList.length - INSERT_INTO_DATA_SEPERATOR.length);
    return columnList;
  }

  String _formatColumnForInsert(String columnName, String columnSuffix) {
    if (columnName != OFFLINE_COLUMNS_MASTER_KEY &&
        columnName != OFFLINE_COLUMNS_STATE) {
      return "[$columnName$columnSuffix]";
    } else {
      return "[$columnName]";
    }
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
        "$OFFLINE_COLUMNS_STATE TEXT$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_SELECTED INTEGER DEFAULT 0$CREATE_TABLE_COLUMNS_SEPERATOR" +
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
