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

import '../model/data/sort_definition.dart';

class SortList extends ListBase<SortDefinition> {
    /// the list of sort definitions
    late List<SortDefinition> list;

    /// the mapping between name and sort definition
    final Map<String, SortDefinition> names = {};

    ///Creates a new SortList with a list of existing elements
    SortList([List<SortDefinition>? items]) {
        list = items ?? List<SortDefinition>.empty(growable: true);

        _update();
    }

    ///Creates a growable list with given [element]
    SortList.fromElement(SortDefinition element) : this(List<SortDefinition>.filled(1, element, growable: true));

    ///Creates a new empty growable
    static SortList empty() {
        return SortList();
    }

    ///Creates a new SortList from an existing list of SortDefinitions
    static SortList? fromList(List<SortDefinition>? items) {
        if (items == null) {
            return null;
        }

        return SortList(items);
    }

    @override
    int get length => list.length;

    @override
    set length(int length) {

        //shorter length means update of cache
        bool update = list.length > length;

        list.length = length;

        if (update) {
            _update();
        }
    }

    @override
    void operator []=(int pos, SortDefinition value) {
        list[pos] = value;

        names[value.columnName] = value;
    }

    @override
    SortDefinition operator [](int pos) => list[pos];

    @override
    void add(SortDefinition element) {
        list.add(element);

        names[element.columnName] = element;
    }

    @override
    void addAll(Iterable<SortDefinition> iterable) {
        list.addAll(iterable);

        _update();
    }

    /// Gets the sort definition by [name]
    SortDefinition? byName(String name) {
        return names[name];
    }

    /// Updates internal element caching
    void _update() {
        names.clear();

        for (int i = 0; i < list.length; i++) {
            names[list[i].columnName] = list[i];
        }
    }
}