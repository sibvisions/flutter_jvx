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

import '../response/application_parameters_response.dart';

class ApplicationParameters {
  String? applicationTitleName;
  String? applicationTitleWeb;
  String? authenticated;
  String? openScreen;
  bool designModeAllowed;
  bool? pushNotificationsEnabled;
  Map<String, dynamic> parameters;

  ApplicationParameters({
    this.applicationTitleName,
    this.applicationTitleWeb,
    this.authenticated,
    this.openScreen,
    bool? designModeAllowed,
    this.pushNotificationsEnabled,
    Map<String, dynamic>? parameters,
  })  : designModeAllowed = designModeAllowed ?? false,
        parameters = parameters ?? {};

  void applyResponse(ApplicationParametersResponse other) {
    applicationTitleName = other.applicationTitleName ?? applicationTitleName;
    applicationTitleWeb = other.applicationTitleWeb ?? applicationTitleWeb;
    authenticated = other.authenticated ?? authenticated;
    openScreen = other.openScreen ?? openScreen;
    designModeAllowed = other.designModeAllowed ?? designModeAllowed;
    pushNotificationsEnabled = other.pushNotificationsEnabled ?? pushNotificationsEnabled;
    parameters = {...parameters, ...(other.json)};
  }
}
