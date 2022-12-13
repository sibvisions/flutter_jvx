/* Copyright 2022 SIB Visions GmbH
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

import 'menu_item_model.dart';

class MenuGroupModel {
  final String name;
  final List<MenuItemModel> items;

  const MenuGroupModel({
    required this.name,
    required this.items,
  });

  ///Makes a deep copy of this object but keeps shallow copies of child objects
  MenuGroupModel copy() {
    return MenuGroupModel(name: name, items: [...items]);
  }
}
