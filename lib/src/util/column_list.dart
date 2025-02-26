/*
 * Copyright 2024 SIB Visions GmbH
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

import 'dart:collection';

import '../model/data/column_definition.dart';

class ColumnList extends ListBase<ColumnDefinition> {
    /// the list of column definitions
    late List<ColumnDefinition> list;

    /// the mapping between name and column definition
    final Map<String, ColumnDefinition> names = {};

    /// the mapping between column name and index in the list
    final Map<String, int> index = {};

    /// the list of column names
    final List<String> listNames = [];

    ///Creates a new ColumnList with a list of existing elements
    ColumnList([List<ColumnDefinition>? items]) {
        list = items ?? List<ColumnDefinition>.empty(growable: true);

        _update();
    }

    ///Creates a growable list with given [element]
    ColumnList.fromElement(ColumnDefinition element) : this(List<ColumnDefinition>.filled(1, element, growable: true));

    ///Creates a new empty growable
    static ColumnList empty() {
        return ColumnList();
    }

    ///Creates a new ColumnList from an existing list of ColumnDefinitions
    static ColumnList? fromList(List<ColumnDefinition>? items) {
        if (items == null) {
            return null;
        }

        return ColumnList(items);
    }

    @override
    int get length => list.length;

    @override
    set length(int length) {

        //shorter length means update of cache
        bool update = list.length > length;

        list.length = length;
        listNames.length = length;

        if (update) {
            _update();
        }
    }

    @override
    void operator []=(int pos, ColumnDefinition value) {
        list[pos] = value;
        listNames[pos] = value.name;

        names[value.name] = value;
        index[value.name] = pos;
    }

    @override
    ColumnDefinition operator [](int pos) => list[pos];

    @override
    void add(ColumnDefinition element) {
        list.add(element);
        listNames.add(element.name);

        names[element.name] = element;
        index[element.name] = list.length - 1;
    }

    @override
    void addAll(Iterable<ColumnDefinition> iterable) {
        list.addAll(iterable);

        _update();
    }

    /// Gets the column definition by [name]
    ColumnDefinition? byName(String name) {
        return names[name];
    }

    /// Gets the index of the column definition by [name]
    int indexByName(String name) {
        return index[name] ?? -1;
    }

    /// Updates internal element caching
    _update() {
        names.clear();
        index.clear();
        listNames.clear();

        String name;

        for (int i = 0; i < list.length; i++) {
            name = list[i].name;

            listNames.add(name);

            names[name] = list[i];
            index[name] = i;
        }
    }
}