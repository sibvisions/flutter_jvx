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

part of 'list_space_builder.dart';

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

class ListSpaceBuilder extends _ListSpaceBuilder {
  const ListSpaceBuilder({required super.args});

  static const kType = 'list_space';

  /// Constant that can be referenced for the builder's type.
  @override
  String get type => kType;

  /// Static function that is capable of decoding the widget from a dynamic JSON
  /// or YAML set of values.
  static ListSpaceBuilder fromDynamic(
    dynamic map, {
    JsonWidgetRegistry? registry,
  }) =>
      ListSpaceBuilder(
        args: map,
      );

  @override
  ListSpaceBuilderModel createModel({
    ChildWidgetBuilder? childBuilder,
    required JsonWidgetData data,
  }) {
    final model = ListSpaceBuilderModel.fromDynamic(
      args,
      registry: data.jsonWidgetRegistry,
    );

    return model;
  }

  @override
  ListSpace buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    final model = createModel(
      childBuilder: childBuilder,
      data: data,
    );

    return ListSpace(
      data: data,
      height: model.height,
      key: key,
      notEmptyColumnNames: model.notEmptyColumnNames,
      text: model.text,
      width: model.width,
    );
  }
}

class JsonListSpace extends JsonWidgetData {
  JsonListSpace({
    Map<String, dynamic> args = const {},
    JsonWidgetRegistry? registry,
    this.height,
    this.notEmptyColumnNames,
    this.text,
    this.width,
  }) : super(
          jsonWidgetArgs: ListSpaceBuilderModel.fromDynamic(
            {
              'height': height,
              'notEmptyColumnNames': notEmptyColumnNames,
              'text': text,
              'width': width,
              ...args,
            },
            args: args,
            registry: registry,
          ),
          jsonWidgetBuilder: () => ListSpaceBuilder(
            args: ListSpaceBuilderModel.fromDynamic(
              {
                'height': height,
                'notEmptyColumnNames': notEmptyColumnNames,
                'text': text,
                'width': width,
                ...args,
              },
              args: args,
              registry: registry,
            ),
          ),
          jsonWidgetType: ListSpaceBuilder.kType,
        );

  final double? height;

  final List<dynamic>? notEmptyColumnNames;

  final String? text;

  final double? width;
}

class ListSpaceBuilderModel extends JsonWidgetBuilderModel {
  const ListSpaceBuilderModel(
    super.args, {
    this.height,
    this.notEmptyColumnNames,
    this.text,
    this.width,
  });

  final double? height;

  final List<dynamic>? notEmptyColumnNames;

  final String? text;

  final double? width;

  static ListSpaceBuilderModel fromDynamic(
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
        '[ListSpaceBuilder]: requested to parse from dynamic, but the input is null.',
      );
    }

    return result;
  }

  static ListSpaceBuilderModel? maybeFromDynamic(
    dynamic map, {
    Map<String, dynamic> args = const {},
    JsonWidgetRegistry? registry,
  }) {
    ListSpaceBuilderModel? result;

    if (map != null) {
      if (map is String) {
        map = yaon.parse(
          map,
          normalize: true,
        );
      }

      if (map is ListSpaceBuilderModel) {
        result = map;
      } else {
        registry ??= JsonWidgetRegistry.instance;
        map = registry.processArgs(map, <String>{}).value;
        result = ListSpaceBuilderModel(
          args,
          height: () {
            dynamic parsed = JsonClass.maybeParseDouble(map['height']);

            return parsed;
          }(),
          notEmptyColumnNames: map['notEmptyColumnNames'],
          text: map['text'],
          width: () {
            dynamic parsed = JsonClass.maybeParseDouble(map['width']);

            return parsed;
          }(),
        );
      }
    }

    return result;
  }

  @override
  Map<String, dynamic> toJson() {
    return JsonClass.removeNull({
      'height': height,
      'notEmptyColumnNames': notEmptyColumnNames,
      'text': text,
      'width': width,
      ...args,
    });
  }
}

class ListSpaceSchema {
  static const id =
      'https://peiffer-innovations.github.io/flutter_json_schemas/schemas/flutter_jvx/list_space.json';

  static final schema = <String, Object>{
    r'$schema': 'http://json-schema.org/draft-07/schema#',
    r'$id': id,
    'title': 'ListSpace',
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'height': SchemaHelper.numberSchema,
      'notEmptyColumnNames': SchemaHelper.anySchema,
      'text': SchemaHelper.stringSchema,
      'width': SchemaHelper.numberSchema,
    },
  };
}
