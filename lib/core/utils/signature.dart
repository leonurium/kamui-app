import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'constants.dart';
import 'device_info.dart';
import 'logger.dart';

class Signature {
  static Future<String> generate() async {
    final deviceId = await DeviceInfoUtil.getDeviceId();
    
    var key = utf8.encode(Constants.secretKey);
    Logger.debug("deviceId: $deviceId", useEmoji: false);
    var message = utf8.encode("$deviceId|${Constants.secretKey}");

    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(message);

    return base64.encode(digest.bytes);
  }
}