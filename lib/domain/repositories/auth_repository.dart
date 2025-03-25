import 'package:kamui_app/domain/entities/device.dart';
import 'package:kamui_app/data/models/main_response.dart';

abstract class AuthRepository {
  Future<MainResponse<Device>> registerDevice(String deviceId, String signature);
}