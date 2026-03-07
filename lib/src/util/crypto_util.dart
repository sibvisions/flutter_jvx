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
import 'package:flutter/services.dart';

import '../flutter_ui.dart';

abstract class CryptoUtil {

  /// Base64 check regexp (see https://github.com/dart-lang/sdk/issues/60436#issuecomment-2768499393)
  static final RegExp rxBase64 = RegExp(r'^(?:[A-Za-z\d+/]{2}(?:==$|[A-Za-z\d+/](?:=$|[A-Za-z\d+/])))*?$');

  // Secure random number generator
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

  static bool maybeEncrypted(String? encrypted) {
    if (encrypted == null) {
      return false;
    }

    if (encrypted.startsWith("{") && encrypted.endsWith("}")) {
      //two keys are enough
      return encrypted.contains('salt') && encrypted.contains('cipher');
    }
    else {
      return false;
    }
  }

  /// Decrypts an [encrypted] text with [keyCode]
  static Future<DecryptedValue> decrypt(String? encrypted, String keyCode) async {
    if (encrypted == null) {
      return DecryptedValue(value: null);
    }

    if (!encrypted.startsWith("{") && !encrypted.endsWith("}")) {
      return DecryptedValue(value: encrypted, type: CryptoValueType.PlainText);
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

      return DecryptedValue(value: utf8.decode(decrypted));
    } on SecretBoxAuthenticationError catch (se) {
      FlutterUI.log.w(se);

      //Wrong key (keyCode or salt)
      return DecryptedValue(value: encrypted, type: CryptoValueType.DecryptFailure);
    } catch (e) {
      FlutterUI.log.e(e);

      return DecryptedValue(value: encrypted, type: CryptoValueType.DecryptFailure);
    }
  }

  ///Checks whether the given [text] is base64 encoded
  static bool isBase64(dynamic text) {
    if (text == null) {
      return false;
    }

    if (text is String) {
      if (text.isEmpty) {
        return false;
      }

      return text.length % 4 == 0 && rxBase64.hasMatch(text);
    }

    return false;
  }

  /// Tries to decode given [base64] text to plain text
  static Uint8List? tryDecodeBase64(String base64) {
    Uint8List? base64Decoded;

    bool decodeDone = false;

    try {
      try {
        if (isBase64(base64)) {
          decodeDone = true;
          base64Decoded = base64Decode(base64);
        }
      }
      catch (ex) {
        if (!decodeDone) {
          //https://github.com/flutter/flutter/issues/165995 -> https://github.com/dart-lang/core/issues/874
          base64Decoded = base64Decode(base64);
        }
      }
    } catch (ex) {
      FlutterUI.log.e(ex);
    }

    return base64Decoded;
  }

}

/// Possible types for crypto values
enum CryptoValueType {
  PlainText,
  Encrypted,
  Decrypted,
  DecryptFailure,
}

/// The DecryptedValue holds a value and type as result of decryption
final class DecryptedValue {

  final CryptoValueType type;
  final dynamic value;

  DecryptedValue({
    this.value,
    this.type = CryptoValueType.Decrypted
  });
}
