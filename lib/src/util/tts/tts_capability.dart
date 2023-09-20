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

import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:universal_io/io.dart';

import '../../service/config/i_config_service.dart';

mixin TtsCapability<T extends StatefulWidget> on State<T> {
  final FlutterTts tts = FlutterTts();
  Future<void>? ttsInit;

  Future<void> initTts() {
    return ttsInit ??= () async {
      await tts.awaitSpeakCompletion(true);
      if (Platform.isIOS || Platform.isMacOS) {
        await tts.autoStopSharedSession(true);
      }
      await tts.setLanguage(IConfigService().getLanguage());
      await tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.interruptSpokenAudioAndMixWithOthers,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }();
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }
}
