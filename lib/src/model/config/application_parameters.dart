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

import '../../service/ui/i_ui_service.dart';
import '../response/application_parameters_response.dart';

class ApplicationParameters {
  String? applicationTitleName;
  String? applicationTitleWeb;
  bool designModeAllowed;
  Map<String, dynamic> parameters;

  ApplicationParameters({
    this.applicationTitleName,
    this.applicationTitleWeb,
    bool? designModeAllowed,
    Map<String, dynamic>? parameters,
  })  : designModeAllowed = designModeAllowed ?? IUiService().applicationParameters.value.designModeAllowed,
        parameters = parameters ?? {};

  void applyResponse(ApplicationParametersResponse other) {
    applicationTitleName = other.applicationTitleName ?? applicationTitleName;
    applicationTitleWeb = other.applicationTitleWeb ?? applicationTitleWeb;
    designModeAllowed = other.designModeAllowed ?? designModeAllowed;
    parameters = {...parameters, ...(other.json)};
  }
}
