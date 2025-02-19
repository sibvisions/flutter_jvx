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

part of 'list_image_builder.dart';

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

class ListImageBuilder extends _ListImageBuilder {
  const ListImageBuilder({required super.args});

  static const kType = 'list_image';

  /// Constant that can be referenced for the builder's type.
  @override
  String get type => kType;

  /// Static function that is capable of decoding the widget from a dynamic JSON
  /// or YAML set of values.
  static ListImageBuilder fromDynamic(
    dynamic map, {
    JsonWidgetRegistry? registry,
  }) =>
      ListImageBuilder(
        args: map,
      );

  @override
  ListImageBuilderModel createModel({
    ChildWidgetBuilder? childBuilder,
    required JsonWidgetData data,
  }) {
    final model = ListImageBuilderModel.fromDynamic(
      args,
      registry: data.jsonWidgetRegistry,
    );

    return model;
  }

  @override
  ListImage buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    final model = createModel(
      childBuilder: childBuilder,
      data: data,
    );

    return ListImage(
      bytes: model.bytes,
      imageDefinition: model.imageDefinition,
      key: key,
      radius: model.radius,
    );
  }
}

class JsonListImage extends JsonWidgetData {
  JsonListImage({
    Map<String, dynamic> args = const {},
    JsonWidgetRegistry? registry,
    this.bytes,
    this.imageDefinition,
    this.radius,
  }) : super(
          jsonWidgetArgs: ListImageBuilderModel.fromDynamic(
            {
              'bytes': bytes,
              'imageDefinition': imageDefinition,
              'radius': radius,
              ...args,
            },
            args: args,
            registry: registry,
          ),
          jsonWidgetBuilder: () => ListImageBuilder(
            args: ListImageBuilderModel.fromDynamic(
              {
                'bytes': bytes,
                'imageDefinition': imageDefinition,
                'radius': radius,
                ...args,
              },
              args: args,
              registry: registry,
            ),
          ),
          jsonWidgetType: ListImageBuilder.kType,
        );

  final Uint8List? bytes;

  final String? imageDefinition;

  final double? radius;
}

class ListImageBuilderModel extends JsonWidgetBuilderModel {
  const ListImageBuilderModel(
    super.args, {
    this.bytes,
    this.imageDefinition,
    this.radius,
  });

  final Uint8List? bytes;

  final String? imageDefinition;

  final double? radius;

  static ListImageBuilderModel fromDynamic(
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
        '[ListImageBuilder]: requested to parse from dynamic, but the input is null.',
      );
    }

    return result;
  }

  static ListImageBuilderModel? maybeFromDynamic(
    dynamic map, {
    Map<String, dynamic> args = const {},
    JsonWidgetRegistry? registry,
  }) {
    ListImageBuilderModel? result;

    if (map != null) {
      if (map is String) {
        map = yaon.parse(
          map,
          normalize: true,
        );
      }

      if (map is ListImageBuilderModel) {
        result = map;
      } else {
        registry ??= JsonWidgetRegistry.instance;
        map = registry.processArgs(map, <String>{}).value;
        result = ListImageBuilderModel(
          args,
          bytes: map['bytes'],
          imageDefinition: map['imageDefinition'],
          radius: () {
            dynamic parsed = JsonClass.maybeParseDouble(map['radius']);

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
      'bytes': bytes,
      'imageDefinition': imageDefinition,
      'radius': radius,
      ...args,
    });
  }
}

class ListImageSchema {
  static const id =
      'https://peiffer-innovations.github.io/flutter_json_schemas/schemas/flutter_jvx/list_image.json';

  static final schema = <String, Object>{
    r'$schema': 'http://json-schema.org/draft-07/schema#',
    r'$id': id,
    'title': 'ListImage',
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'bytes': SchemaHelper.anySchema,
      'imageDefinition': SchemaHelper.stringSchema,
      'radius': SchemaHelper.numberSchema,
    },
  };
}
