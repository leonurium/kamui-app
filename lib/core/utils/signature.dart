import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'device_info.dart';
import '../config/constants.dart';

class Signature {
  static Future<String> generate() async {
    final deviceId = await DeviceInfoUtil.getDeviceId();
    
    var key = utf8.encode(Constants.secretKey);
    var message = utf8.encode("$deviceId|${Constants.secretKey}");

    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(message);

    return base64.encode(digest.bytes);
  }
}