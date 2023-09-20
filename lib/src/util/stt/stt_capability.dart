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

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:speech_to_text/speech_recognition_event.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

mixin SttCapability<T extends StatefulWidget> on State<T> {
  static final SpeechToText speechToText = SpeechToText();
  static final SpeechToTextProvider speechToTextProvider = SpeechToTextProvider(speechToText);

  SpeechToText get stt => SttCapability.speechToText;

  SpeechToTextProvider get sttProvider => SttCapability.speechToTextProvider;

  StreamSubscription<SpeechRecognitionEvent>? subscription;

  bool? speechAvailable;
  Future<void>? sttInit;

  Future<void> initStt() async {
    await (sttInit ??= () async {
      speechAvailable = await speechToTextProvider.initialize(
        options: [
          SpeechToText.androidNoBluetooth,
          SpeechToText.iosNoBluetooth,
        ],
      );
    }());
    setState(() {});
    await subscription?.cancel();
    subscription = speechToTextProvider.stream.listen(onSttEvent);
  }

  void onSttEvent(SpeechRecognitionEvent event) {}

  @override
  void dispose() {
    subscription?.cancel();
    sttProvider.cancel();
    super.dispose();
  }
}
