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
import '../../util/column_list.dart';
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlListEntry({super.key, required super.model, this.slideController, this.slideActionFactory, required this.columnDefinitions, required this.values, required this.index, required this.isSelected, this.recordFormat, this.template, this.onDismissed});

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

      //similar code is in fl_table_wrapper.dart -> _getColumnsToShow
      model.columnNames.forEach((colName) {
        ColumnDefinition? cd = columnDefinitions.byName(colName);

        if (cd != null) {
          int cdIndex = columnDefinitions.indexOf(cd);

          registry.setValue(colName, values[cdIndex]);
        }
      });

      return JsonWidgetData.fromDynamic(
        jsonDecode(jsonTemplate),
        registry: registry,
      ).build(context: context);
    }

    return null;
  }

  Widget _defaultEntry(BuildContext context) {
      return Container(height: 30, color: Colors.red.shade300);
  }
}
