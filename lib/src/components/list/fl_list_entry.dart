/*
 * Copyright 2025 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

import '../../../flutter_jvx.dart';
import '../../model/response/record_format.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../util/column_list.dart';
import '../../util/i_types.dart';
import 'list_image_builder.dart';

typedef DismissedCallback = void Function(int index);

class FlListEntry extends FlStatelessWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The colum definitions to build
  final ColumnList columnDefinitions;

  /// The value of the cell
  final List<dynamic> values;

  /// The index of the row this column is in
  final int index;

  /// If this row is selected
  final bool isSelected;

  /// If vertical centered
  final bool verticalCenter;

  /// The record formats
  final RecordFormat? recordFormat;

  /// custom card template as json
  final String? template;

  final Map<int, int>? columnsPerRow;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlListEntry({super.key,
    required super.model,
    required this.columnDefinitions,
    required this.values,
    required this.index,
    required this.isSelected,
    this.recordFormat,
    this.template,
    this.columnsPerRow,
    this.verticalCenter = false});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    Widget? card;

    if (template != null) {
      card = _fromTemplate(
        context,
        template!,
      );
    }

    return card ?? _defaultEntry(context);
  }

  Widget? _fromTemplate(BuildContext context, String template) {
    String? jsonTemplate;

    String tplUrl = template;
    if (tplUrl.startsWith("/")) {
      tplUrl = tplUrl.substring(1);
    }

    if (!kIsWeb) {
      String? appVersion = IConfigService().version.value;

      if (appVersion != null) {
        IFileManager fileManager = IConfigService().getFileManager();

        String path = fileManager.getAppSpecificPath(
          "${IFileManager.TEMPLATES_PATH}/$tplUrl",
          appId: IConfigService().currentApp.value!,
          version: appVersion,
        );

        File? file = fileManager.getFileSync(path);

        if (file?.existsSync() == true) {
          jsonTemplate = file!.readAsStringSync();
        }
      }
    } else {
      Uri baseUrl = IConfigService().baseUrl.value!;
      String appName = IConfigService().appName.value!;

      //imageProvider = NetworkImage("$baseUrl/resource/$appName/$imageDefinition_", headers: _getHeaders());
    }

    if (jsonTemplate != null) {
      final registry = JsonWidgetRegistry.instance;

      registry.registerCustomBuilder("list_image", const JsonWidgetBuilderContainer(builder: ListImageBuilder.fromDynamic));
      registry.clearValues();

      for (int i = 0; i < model.columnNames.length; i++) {
        int columnIndex = columnDefinitions.indexByName(model.columnNames[i]);

        if (columnIndex >= 0) {
          registry.setValue(model.columnNames[i], values[columnIndex]);
        }
      }

      return JsonWidgetData.fromDynamic(
        jsonDecode(jsonTemplate),
        registry: registry,
      ).build(context: context);
    }

    return null;
  }

  Widget _defaultEntry(BuildContext context) {
/*
    return Container(color: Colors.grey, child: Padding(padding: EdgeInsets.all(0), child: Container(color: Colors.yellow, child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:
    [
      Container(color: Colors.red, child: Column(children: [Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Icon(Icons.arrow_forward_ios,
              color: Colors.grey.shade300)
      )])),
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [Text("A"), Text("B"), Text("C"), Text("D"), Text("E")],),
    ],))));
*/
    String? imageColumn;
    List<String> valueColumns = [];

    for (int i = 0; i < model.columnNames.length; i++) {
      int columnIndex = columnDefinitions.indexByName(model.columnNames[i]);

      if (columnIndex >= 0) {
        ColumnDefinition cdef = columnDefinitions[columnIndex];

        if (cdef.dataTypeIdentifier == Types.BINARY) {
          //fifo
          imageColumn ??= model.columnNames[i];
        }
        else if (FlCellEditorClassname.CHOICE_CELL_EDITOR != cdef.cellEditorClassName &&
              FlCellEditorClassname.CHECK_BOX_CELL_EDITOR != cdef.cellEditorClassName) {
          valueColumns.add(model.columnNames[i]);
        }
      }
    }

    int maxColumns = valueColumns.length;
    int colPos = 0;
    int cols;

    List<Widget> liRows = [];

    Row? row;

    dynamic value;
    String valueAsText;

    //We use the theme style and ignore card styling
    TextStyle? textStyle = Theme.of(context).textTheme.labelLarge;

    print(math.max(3, columnsPerRow?.length ?? 0));


    //we show per default max. 3 Rows, but it's possible to show more than 1 column per row
    //also if more rows are defined per columns, it's possible to have more than 3 rows
    for (int i = 0; i < math.max(3, columnsPerRow?.length ?? 0) && colPos < maxColumns; i++) {
      row = null;

      if (columnsPerRow?[i] != null) {
        cols = columnsPerRow![i]!;

        List<Widget> liColumns = [];

        for (int j = 0; j < cols && colPos < maxColumns; j++) {
          value = values[columnDefinitions.indexByName(valueColumns[colPos++])];

          if (value != null) {
            valueAsText = value.toString();
          }
          else {
            valueAsText = "";
          }

          if (liColumns.isNotEmpty && valueAsText.isNotEmpty && j > 0) {
            valueAsText = " $valueAsText";
          }

          if (valueAsText.isNotEmpty) {
            liColumns.add(Text(valueAsText, style: textStyle));
          }
        }

        if (liColumns.isNotEmpty) {
          row = Row(children: liColumns);
        }
      }
      else {
        value = values[columnDefinitions.indexByName(valueColumns[colPos++])];

        if (value != null) {
          valueAsText = value.toString();
        }
        else {
          valueAsText = "";
        }

        if (valueAsText.isNotEmpty) {
          row = Row(children: [Text(valueAsText, style: textStyle)]);
        }
      }

      //if we don't have a image column -> show exactly 3 rows, otherwise rows have different height
      if (row == null && imageColumn == null) {
        row = Row(children: [Text("", style: textStyle)]);
      }

      if (row != null) {
        liRows.add(row);

        if (liRows.length > 1) {
          //Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
          liRows[liRows.length - 1] = Padding(padding: const EdgeInsets.only(top: 5), child: liRows[liRows.length - 1]);
        }
      }
    }

    Widget? w;

    if (imageColumn != null) {
      w = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListImage(imageDefinition: values[columnDefinitions.indexByName(imageColumn)])
              )
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                child: Column(
                  mainAxisAlignment: verticalCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: liRows
                )
              )
            )
          ]
        )
      );
    }
    else {
      w = Padding(
            padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
            child: Column(
                    mainAxisAlignment: verticalCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: liRows)
          );
    }

    return w ?? Container(height: 30, color: Colors.red.shade300);
  }
}
