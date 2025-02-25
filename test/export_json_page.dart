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

import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class ExportJsonPage extends StatefulWidget {

    final int mode;

    const ExportJsonPage(this.mode, {super.key});

    @override
    State createState() => _ExportExamplePageState();
}

class _ExportExamplePageState extends State<ExportJsonPage> {
    final GlobalKey<JsonWidgetExporterData> _exportKey = GlobalKey<JsonWidgetExporterData>();

    int _count = 1;

    @override
    Widget build(BuildContext context) {
        final registry = JsonWidgetRegistry();

        registry.setValue('count', _count);
        registry.setValue('increment', () => () => setState(() => _count++));

        return Scaffold(
            appBar: AppBar(
                actions: [
                    IconButton(
                        icon: const Icon(
                            Icons.copy,
                            color: Colors.white,
                        ),
                        onPressed: () {
                            final data = _exportKey.currentState!.export(
                                indent: '  ',
                                mode: ReverseEncodingMode.json,
                            );

                            if (kDebugMode) {
                                print(data);
                            }

                            Clipboard.setData(ClipboardData(text: data));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Copied to clipboard'),
                                ),
                            );
                        },
                    ),
                ],
                backgroundColor: Colors.black,
                title: const Text(
                    'Exporter',
                    style: TextStyle(
                        color: Colors.white,
                    ),
                ),
            ),
            body: JsonWidgetExporter(
                key: _exportKey,
                child: JsonExportable(
                    child: _createWidgetData(registry, widget.mode),
                ),
            ),
        );
    }

    JsonWidgetData _createWidgetData(JsonWidgetRegistry registry, int mode) {

        switch (mode)
        {
            case 0:
                return JsonContainer(
                    color: Colors.grey,
                    foregroundDecoration: null,
                    decoration: null,
                    child: JsonRow(
                        children: [
                            JsonPadding(padding: const EdgeInsets.all(5), child: JsonText("Welcome"),),
                            JsonIcon(Icons.add,
                                color: Colors.grey.shade400),
                            JsonIcon(FontAwesomeIcons.adn,
                                color: Colors.red),
                            JsonMemoryImage(image: "")
                        ]));
            default:
                return JsonScaffold(
                    appBar: JsonAppBar(
                        title: JsonText('Example'),
                    ),
                    body: JsonListView(
                        children: [
                            for (var i = 0; i < _count; i++)
                                JsonListTile(
                                    subtitle: JsonText(
                                        args: {
                                            'text': r'${i + 1}',
                                        },
                                        registry: JsonWidgetRegistry(
                                            parent: registry,
                                            values: {
                                                'i': i,
                                            },
                                        ),
                                        '${i + 1}',
                                    ),
                                    title: JsonText('ListTile'),
                                ),
                        ],
                    ),
                    floatingActionButton: JsonFloatingActionButton(
                        args: {
                            'onPressed': r'${increment()}',
                        },
                        registry: registry,
                        onPressed: () => setState(() => _count++),
                        child: JsonIcon(Icons.add),
                    ),
                );
        }

    }
}