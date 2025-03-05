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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_cell_builder.dart';

// **************************************************************************
// Generator: JsonWidgetLibraryBuilder
// **************************************************************************

// ignore_for_file: avoid_init_to_null
// ignore_for_file: deprecated_member_use

// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_constructors_in_immutables
// ignore_for_file: prefer_final_locals
// ignore_for_file: prefer_if_null_operators
// ignore_for_file: prefer_single_quotes
// ignore_for_file: unused_local_variable

class ListCellBuilder extends _ListCellBuilder {
  const ListCellBuilder({required super.args});

  static const kType = 'list_cell';

  /// Constant that can be referenced for the builder's type.
  @override
  String get type => kType;

  /// Static function that is capable of decoding the widget from a dynamic JSON
  /// or YAML set of values.
  static ListCellBuilder fromDynamic(
    dynamic map, {
    JsonWidgetRegistry? registry,
  }) =>
      ListCellBuilder(
        args: map,
      );

  @override
  ListCellBuilderModel createModel({
    ChildWidgetBuilder? childBuilder,
    required JsonWidgetData data,
  }) {
    final model = ListCellBuilderModel.fromDynamic(
      args,
      registry: data.jsonWidgetRegistry,
    );

    return model;
  }

  @override
  ListCell buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    final model = createModel(
      childBuilder: childBuilder,
      data: data,
    );

    return ListCell(
      columnName: model.columnName,
      data: data,
      key: key,
      postfix: model.postfix,
      prefix: model.prefix,
      useFormat: model.useFormat,
      wrappedWidget: model.wrappedWidget,
    );
  }
}

class JsonListCell extends JsonWidgetData {
  JsonListCell({
    Map<String, dynamic> args = const {},
    JsonWidgetRegistry? registry,
    this.columnName,
    this.postfix,
    this.prefix,
    this.useFormat = true,
    this.wrappedWidget,
  }) : super(
          jsonWidgetArgs: ListCellBuilderModel.fromDynamic(
            {
              'columnName': columnName,
              'postfix': postfix,
              'prefix': prefix,
              'useFormat': useFormat,
              'wrappedWidget': wrappedWidget,
              ...args,
            },
            args: args,
            registry: registry,
          ),
          jsonWidgetBuilder: () => ListCellBuilder(
            args: ListCellBuilderModel.fromDynamic(
              {
                'columnName': columnName,
                'postfix': postfix,
                'prefix': prefix,
                'useFormat': useFormat,
                'wrappedWidget': wrappedWidget,
                ...args,
              },
              args: args,
              registry: registry,
            ),
          ),
          jsonWidgetType: ListCellBuilder.kType,
        );

  final String? columnName;

  final String? postfix;

  final String? prefix;

  final bool useFormat;

  final dynamic wrappedWidget;
}

class ListCellBuilderModel extends JsonWidgetBuilderModel {
  const ListCellBuilderModel(
    super.args, {
    this.columnName,
    this.postfix,
    this.prefix,
    this.useFormat = true,
    this.wrappedWidget,
  });

  final String? columnName;

  final String? postfix;

  final String? prefix;

  final bool useFormat;

  final dynamic wrappedWidget;

  static ListCellBuilderModel fromDynamic(
    dynamic map, {
    Map<String, dynamic> args = const {},
    JsonWidgetRegistry? registry,
  }) {
    final result = maybeFromDynamic(
      map,
      args: args,
      registry: registry,
    );

    if (result == null) {
      throw Exception(
        '[ListCellBuilder]: requested to parse from dynamic, but the input is null.',
      );
    }

    return result;
  }

  static ListCellBuilderModel? maybeFromDynamic(
    dynamic map, {
    Map<String, dynamic> args = const {},
    JsonWidgetRegistry? registry,
  }) {
    ListCellBuilderModel? result;

    if (map != null) {
      if (map is String) {
        map = yaon.parse(
          map,
          normalize: true,
        );
      }

      if (map is ListCellBuilderModel) {
        result = map;
      } else {
        registry ??= JsonWidgetRegistry.instance;
        map = registry.processArgs(map, <String>{}).value;
        result = ListCellBuilderModel(
          args,
          columnName: map['columnName'],
          postfix: map['postfix'],
          prefix: map['prefix'],
          useFormat: JsonClass.parseBool(
            map['useFormat'],
            whenNull: true,
          ),
          wrappedWidget: map['wrappedWidget'],
        );
      }
    }

    return result;
  }

  @override
  Map<String, dynamic> toJson() {
    return JsonClass.removeNull({
      'columnName': columnName,
      'postfix': postfix,
      'prefix': prefix,
      'useFormat': true == useFormat ? null : useFormat,
      'wrappedWidget': wrappedWidget,
      ...args,
    });
  }
}

class ListCellSchema {
  static const id =
      'https://peiffer-innovations.github.io/flutter_json_schemas/schemas/flutter_jvx/list_cell.json';

  static final schema = <String, Object>{
    r'$schema': 'http://json-schema.org/draft-07/schema#',
    r'$id': id,
    'title': 'ListCell',
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'columnName': SchemaHelper.stringSchema,
      'postfix': SchemaHelper.stringSchema,
      'prefix': SchemaHelper.stringSchema,
      'useFormat': SchemaHelper.boolSchema,
      'wrappedWidget': SchemaHelper.anySchema,
    },
  };
}
