/*
 * Copyright 2026 SIB Visions GmbH
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

import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

abstract class HapticUtil {

  /// [HapticFeedback.lightImpact]
  static Future<void> light() async {
    if (await Haptics.canVibrate()) {
      await Haptics.vibrate(HapticsType.light);
    }
    else {
      await HapticFeedback.lightImpact();
    }
  }

  /// [HapticFeedback.mediumImpact]
  static Future<void> medium() async {
    if (await Haptics.canVibrate()) {
      await Haptics.vibrate(HapticsType.medium);
    }
    else {
      await HapticFeedback.mediumImpact();
    }
  }

  /// [HapticFeedback.heavyImpact]
  static Future<void> heavy() async {
    if (await Haptics.canVibrate()) {
      await Haptics.vibrate(HapticsType.heavy);
    }
    else {
      await HapticFeedback.heavyImpact();
    }
  }

  /// [HapticFeedback.selectionClick]
  static Future<void> selection() async {
    if (await Haptics.canVibrate()) {
      await Haptics.vibrate(HapticsType.selection);
    }
    else {
      await HapticFeedback.selectionClick();
    }
  }

  /// [HapticFeedback.errorNotification]
  static Future<void> error() async {
    if (await Haptics.canVibrate()) {
      await Haptics.vibrate(HapticsType.error);
    }
    else {
      await HapticFeedback.errorNotification();
    }
  }

  /// [HapticFeedback.vibrate]
  static Future<void> vibrate() async {
    if (await Haptics.canVibrate()) {
      await Haptics.vibrate(HapticsType.success);
    }
    else {
      await HapticFeedback.vibrate();
    }
  }
}
