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

import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../flutter_ui.dart';

abstract class CryptoUtil {
  static final _secureRandom = Random.secure();

  //Generates salt with given number of bytes
  static List<int> _generateSalt(int length) {
    return List<int>.generate(length, (_) => _secureRandom.nextInt(256));
  }

  /// Derives a key from a key code (maybe an appId)
  static Future<SecretKey> _deriveKey(String keyCode, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 50000,
      bits: 256,
    );

    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(keyCode)),
      nonce: salt,
    );
  }

  /// Encrypts a [text] with [keyCode]
  static Future<String> encrypt(String text, String keyCode) async {
    try {
      final algorithm = AesGcm.with256bits();
      final salt = _generateSalt(16);

      final key = await _deriveKey(keyCode, salt);

      final nonce = algorithm.newNonce();

      final secretBox = await algorithm.encrypt(
        utf8.encode(text),
        secretKey: key,
        nonce: nonce);

      return jsonEncode({
        "salt": base64Encode(salt),
        "nonce": base64Encode(secretBox.nonce),
        "cipher": base64Encode(secretBox.cipherText),
        "mac": base64Encode(secretBox.mac.bytes)
      });
    } catch (e) {
      FlutterUI.log.e(e);

      rethrow;
    }
  }

  /// Decrypts an [encrypted] text with [keyCode]
  static Future<String?> decrypt(String? encrypted, String keyCode) async {
    if (encrypted == null) {
      return null;
    }

    if (!encrypted.startsWith("{") && !encrypted.endsWith("}")) {
      return encrypted;
    }

    try {
      final algorithm = AesGcm.with256bits();
      final map = jsonDecode(encrypted);

      final key = await _deriveKey(
        keyCode,
        base64Decode(map["salt"])
      );

      final secretBox = SecretBox(
        base64Decode(map['cipher']),
        nonce: base64Decode(map['nonce']),
        mac: Mac(base64Decode(map['mac'])),
      );

      final decrypted = await algorithm.decrypt(
        secretBox,
        secretKey: key,
      );

      return utf8.decode(decrypted);
    } on SecretBoxAuthenticationError catch (se) {
      FlutterUI.log.e(se);
      //Wrong key (keyCode or salt)
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
