/*
 * Copyright 2023 SIB Visions GmbH
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

import 'route_command.dart';
import 'route_to_login_command.dart';
import 'route_to_menu_command.dart';
import 'route_to_work_command.dart';

/// Command to route to a general uri.
///
/// See also:
/// * [RouteToLoginCommand]
/// * [RouteToMenuCommand]
/// * [RouteToWorkCommand]
class RouteToCommand extends RouteCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String uri;

  /// Whether the route should replace the the current one in the stack.
  final bool replaceRoute;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  RouteToCommand({
    required this.uri,
    this.replaceRoute = false,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "RouteToCommand{uri: $uri, replaceRoute: $replaceRoute, ${super.toString()}}";
  }
}
