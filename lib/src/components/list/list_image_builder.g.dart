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
// ignore_for_file: library_private_types_in_public_api
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
  _ListImage buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    final model = createModel(
      childBuilder: childBuilder,
      data: data,
    );

    return _ListImage(
      bytes: model.bytes,
      height: model.height,
      imageDefinition: model.imageDefinition,
      width: model.width,
    );
  }
}

class JsonListImage extends JsonWidgetData {
  JsonListImage({
    Map<String, dynamic> args = const {},
    JsonWidgetRegistry? registry,
    this.bytes,
    this.height,
    this.imageDefinition,
    this.width,
  }) : super(
          jsonWidgetArgs: ListImageBuilderModel.fromDynamic(
            {
              'bytes': bytes,
              'height': height,
              'imageDefinition': imageDefinition,
              'width': width,
              ...args,
            },
            args: args,
            registry: registry,
          ),
          jsonWidgetBuilder: () => ListImageBuilder(
            args: ListImageBuilderModel.fromDynamic(
              {
                'bytes': bytes,
                'height': height,
                'imageDefinition': imageDefinition,
                'width': width,
                ...args,
              },
              args: args,
              registry: registry,
            ),
          ),
          jsonWidgetType: ListImageBuilder.kType,
        );

  final Uint8List? bytes;

  final double? height;

  final String? imageDefinition;

  final double? width;
}

class ListImageBuilderModel extends JsonWidgetBuilderModel {
  const ListImageBuilderModel(
    super.args, {
    this.bytes,
    this.height,
    this.imageDefinition,
    this.width,
  });

  final Uint8List? bytes;

  final double? height;

  final String? imageDefinition;

  final double? width;

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
          height: () {
            dynamic parsed = JsonClass.maybeParseDouble(map['height']);

            return parsed;
          }(),
          imageDefinition: map['imageDefinition'],
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
      'bytes': bytes,
      'height': height,
      'imageDefinition': imageDefinition,
      'width': width,
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
    'title': '_ListImage',
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'bytes': SchemaHelper.anySchema,
      'height': SchemaHelper.numberSchema,
      'imageDefinition': SchemaHelper.stringSchema,
      'width': SchemaHelper.numberSchema,
    },
  };
}
