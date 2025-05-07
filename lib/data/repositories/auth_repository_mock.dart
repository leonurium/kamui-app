import 'package:kamui_app/domain/entities/device.dart';
import 'package:kamui_app/domain/repositories/auth_repository.dart';
import 'package:kamui_app/data/models/main_response.dart';

class AuthRepositoryMock implements AuthRepository {
  @override
  Future<MainResponse<Device>> registerDevice(String deviceId, String signature) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    
    final now = DateTime.now();
    final device = Device(
      id: 1,
      deviceId: deviceId,
      isPremium: false,
      expiresAt: null,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
    
    return MainResponse<Device>(
      success: true,
      message: 'Device registered successfully',
      data: device,
    );
  }
} 