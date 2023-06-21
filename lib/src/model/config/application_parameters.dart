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
  })  : designModeAllowed = designModeAllowed ?? false,
        parameters = parameters ?? {};

  void merge(ApplicationParameters other) {
    applicationTitleName = other.applicationTitleName ?? applicationTitleName;
    applicationTitleWeb = other.applicationTitleWeb ?? applicationTitleWeb;
    designModeAllowed = other.designModeAllowed;
    parameters = other.parameters;
  }
}
