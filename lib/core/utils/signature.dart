import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'device_info.dart';
import '../config/constants.dart';

class Signature {
  static Future<String> generate() async {
    final deviceId = await DeviceInfoUtil.getDeviceId();
    
    final key = utf8.encode(Constants.secretKey);
    final message = utf8.encode("$deviceId|${Constants.secretKey}");

    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(message);

    return base64.encode(digest.bytes);
  }
}