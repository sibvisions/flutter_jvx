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

import 'package:avatars/avatars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  // Callbacks
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The callback for dismissed row
  final DismissedCallback? onDismissed;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The colum definitions to build.
  final ColumnList columnDefinitions;

  /// The value of the cell;
  final List<dynamic> values;

  /// The index of the row this column is in.
  final int index;

  /// If this row is selected.
  final bool isSelected;

  /// The record formats
  final RecordFormat? recordFormat;

  /// the slide controller
  final SlidableController? slideController;

  /// Which slide actions are to be allowed to the row.
  final TableSlideActionFactory? slideActionFactory;

  /// custom card template as json
  final String? template;

  final Map<int, int>? columnsPerRow;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlListEntry({super.key,
    required super.model,
    this.slideController,
    this.slideActionFactory,
    required this.columnDefinitions,
    required this.values,
    required this.index,
    required this.isSelected,
    this.recordFormat,
    this.template,
    this.columnsPerRow,
    this.onDismissed});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    Widget card = _createCard(context);

    List<SlidableAction> slideActions = slideActionFactory?.call(context, index) ?? [];

    return Theme(
      data: Theme.of(context).copyWith(outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(iconColor: slideActions.isNotEmpty ? slideActions.first.foregroundColor : Colors.white, textStyle: const TextStyle(fontWeight: FontWeight.normal), iconSize: 16))),
      child: Slidable(
          key: UniqueKey(),
          controller: slideController,
          closeOnScroll: true,
          direction: Axis.horizontal,
          enabled: slideActionFactory != null && slideActions.isNotEmpty == true && model.isEnabled,
          groupTag: slideActionFactory,
          endActionPane: ActionPane(
            extentRatio: 0.50,
            dismissible: DismissiblePane(
              closeOnCancel: true,
              onDismissed: () {
                if (onDismissed != null) {
                  onDismissed!(index);
                }
                slideActions.last.onPressed!(context);
              },
            ),
            motion: const StretchMotion(),
            children: slideActions,
          ),
          child: card),
    );
  }

  Widget _createCard(BuildContext context) {
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

    Widget? w;

    if (imageColumn != null) {
        w = Row(children: [
            Container(
                color: Colors.grey.shade200,
                child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(children:
                    [
                      ListImage(imageDefinition: values[columnDefinitions.indexByName(imageColumn)])
                    ]
                    ))),
            Expanded(child: Padding(padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5), child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("A"), Text("B"), Text("C")])))
        ]);
//        w = Padding(padding: const EdgeInsets.only(top: 1, bottom: 1), child: w);
    }

    return w ?? Container(height: 30, color: Colors.red.shade300);
  }
}
