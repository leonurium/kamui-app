import '../repositories/auth_repository.dart';
import 'package:kamui_app/data/models/main_response.dart';
import 'package:kamui_app/domain/entities/device.dart';

class RegisterDeviceUseCase {
  final AuthRepository repository;

  RegisterDeviceUseCase(this.repository);
 
  Future<MainResponse<Device>> execute(String deviceId, String signature) {
    return repository.registerDevice(deviceId, signature);
  }
}