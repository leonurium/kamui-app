abstract class AuthRepository {
  Future<bool> registerDevice(String deviceId, String signature);
}