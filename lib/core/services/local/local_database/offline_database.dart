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
const String OFFLINE_COLUMNS_INSERTED = "off_inserted";
const String OFFLINE_COLUMNS_UPDATED = "off_updated";
const String OFFLINE_COLUMNS_DELETED = "off_deleted";
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

  Future<bool> insertRows(DataBook data) async {
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

          if (failedInsertCount > 0) {
            return false;
          } else {
            return true;
          }
        });
      }
    }
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

    columnList = columnList.substring(
        0, columnList.length - INSERT_INTO_DATA_SEPERATOR.length);
    return columnList;
  }

  String _formatColumnForInsert(String columnName, String columnSuffix) {
    if (columnName != OFFLINE_COLUMNS_MASTER_KEY &&
        columnName != OFFLINE_COLUMNS_INSERTED) {
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
        "$OFFLINE_COLUMNS_INSERTED INTEGER DEFAULT 0$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_UPDATED INTEGER DEFAULT 0$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_DELETED INTEGER DEFAULT 0$CREATE_TABLE_COLUMNS_SEPERATOR" +
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
