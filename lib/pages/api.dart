import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

class ApiReturn {
  String decryptPublicKey(String public, String content){
    RSAKeyParser parser = RSAKeyParser();
    RSAPublicKey publicKey = parser.parse(public) as RSAPublicKey;
    AsymmetricBlockCipher cipher = PKCS1Encoding(RSAEngine());
    cipher
      .init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
    return utf8.decode(cipher.process(Encrypted.fromBase64(content).bytes));
  }

  String encrypt(String plaintext, RSAPublicKey publicKey) {
    var cipher = new RSAEngine()
      ..init(true, new PublicKeyParameter<RSAPublicKey>(publicKey));
    var cipherText =
        cipher.process(new Uint8List.fromList(plaintext.codeUnits));

    return new String.fromCharCodes(cipherText);
  }

  String decrypt(String ciphertext, RSAPublicKey publickey) {
    var cipher = new RSAEngine()
      ..init(false, new PublicKeyParameter<RSAPublicKey>(publickey));
    var decrypted = cipher.process(new Uint8List.fromList(ciphertext.codeUnits));

    return new String.fromCharCodes(decrypted);
  }
}