import '../repositories/auth_repository.dart';

class RegisterDeviceUseCase {
  final AuthRepository repository;

  RegisterDeviceUseCase(this.repository);

  Future<bool> execute(String deviceId, String signature) {
    return repository.registerDevice(deviceId, signature);
  }
}