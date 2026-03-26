/*
 * Copyright 2022 SIB Visions GmbH
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

import 'package:flutter/material.dart';

class FlTabController extends TabController {
  List<bool>? enabledState;

  FlTabController({
    super.length = 0,
    super.initialIndex,
    required super.vsync,
    this.enabledState}
  );

  bool isAllowedToAnimate() {
    bool isAllowed = offset == 0.0 && !indexIsChanging;

    if (isAllowed && animation != null) {
      isAllowed = (animation!.value - animation!.value.floor()) == 0;
    }

    return isAllowed;
  }

  @override
  void animateTo(int value, {Duration? duration, Curve curve = Curves.ease}) {
    duration ??= kTabScrollDuration;

    if (isTabEnabled(value) && isAllowedToAnimate()) {
      super.animateTo(value, duration: duration, curve: curve);
    }
  }

  bool isTabEnabled(int value) {
    if (enabledState == null || value >= enabledState!.length) {
      return true;
    }

    return enabledState![value];
  }
}
