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
import 'package:flutter/foundation.dart';
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

  /// Encrypts a binary or string with [keyCode]
  static Future<String> encrypt(dynamic value, String keyCode) async {
    return compute(_executeEncryption, (value, keyCode));
  }

  static Future<String> _executeEncryption((dynamic, String) args) async {
    final value = args.$1;
    final keyCode = args.$2;

    try {
      final algorithm = AesGcm.with256bits();
      final salt = _generateSalt(16);

      final key = await _deriveKey(keyCode, salt);
      final nonce = algorithm.newNonce();

      final secretBox = await algorithm.encrypt(
        value is Uint8List ? value : utf8.encode(value.toString()),
        secretKey: key,
        nonce: nonce,
      );

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
    return compute(_executeDecryption, (encrypted, keyCode));
  }

  static Future<DecryptedValue> _executeDecryption((String?, String) args) async {
    final String? encrypted = args.$1; // Holt den ersten Wert (encrypted)
    final String keyCode = args.$2;    // Holt den zweiten Wert (keyCode)

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
        base64Decode(map["salt"]),
      );

      final secretBox = SecretBox(
        base64Decode(map["cipher"]),
        nonce: base64Decode(map["nonce"]),
        mac: Mac(base64Decode(map["mac"])),
      );

      final decrypted = await algorithm.decrypt(
        secretBox,
        secretKey: key,
      );

      return DecryptedValue(value: decrypted);
    } on SecretBoxAuthenticationError catch (se) {
      FlutterUI.log.w(se);

      return DecryptedValue(value: encrypted, type: CryptoValueType.DecryptFailure);
    } catch (e, stack) {
      FlutterUI.log.e(e, error: e, stackTrace: stack);

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

  /// Generates a random password
  static String generatePassword({
    int? length,
    String? allowedChars,
    String? specialChars,
    int? minSpecialChars,
  }) {
    // Falls ein Parameter null ist, greift der Wert hinter dem ??
    final int length_ = length ?? 12;
    final String allowedChars_ = allowedChars ?? 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final String specialChars_ = specialChars ?? r'$!@#%^&*()_+{}[]|:;<>,.?/~';
    final int minSpecialChars_ = minSpecialChars ?? 2;

    if (length_ < minSpecialChars_) {
      throw ArgumentError('Total length cannot be less than the minimum number of special characters.');
    }
    if (allowedChars_.isEmpty && minSpecialChars_ < length_) {
      throw ArgumentError('Allowed characters list cannot be empty when password length needs to be filled.');
    }
    if (specialChars_.isEmpty && minSpecialChars_ > 0) {
      throw ArgumentError('Special characters list cannot be empty when a minimum number of special characters is required.');
    }

    final Random random = Random.secure();
    List<String> passwordChars = [];

    // Add special chars
    for (int i = 0; i < minSpecialChars_; i++) {
      int index = random.nextInt(specialChars_.length);
      passwordChars.add(specialChars_[index]);
    }

    // fill with other chars
    int remainingLength = length_ - minSpecialChars_;
    for (int i = 0; i < remainingLength; i++) {
      int index = random.nextInt(allowedChars_.length);
      passwordChars.add(allowedChars_[index]);
    }

    // mix it
    passwordChars.shuffle(random);

    return passwordChars.join('');
  }

  /// Current string to hex representation
  static String toHex(List<int> bytes) {
    final StringBuffer buffer = StringBuffer();

    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }

    return buffer.toString();
  }

}

/// Possible types for crypto values
enum CryptoValueType {
  PlainText,
  Encrypted,
  Decrypted,
  DecryptFailure,
  Lazy
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
