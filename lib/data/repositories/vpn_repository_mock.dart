import 'package:kamui_app/domain/entities/server.dart';
import 'package:kamui_app/domain/entities/session.dart';
import 'package:kamui_app/domain/repositories/vpn_repository.dart';

class VpnRepositoryMock implements VpnRepository {
  @override
  Future<List<Server>> getServers() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    
    return [
      Server(
        id: 1,
        apiUrl: 'https://us-server.example.com',
        country: 'United States',
        city: 'New York',
        isLocked: false,
        isPremium: false,
      ),
      Server(
        id: 2,
        apiUrl: 'https://uk-server.example.com',
        country: 'United Kingdom',
        city: 'London',
        isLocked: false,
        isPremium: true,
      ),
      Server(
        id: 3,
        apiUrl: 'https://jp-server.example.com',
        country: 'Japan',
        city: 'Tokyo',
        isLocked: false,
        isPremium: true,
      ),
      Server(
        id: 4,
        apiUrl: 'https://sg-server.example.com',
        country: 'Singapore',
        city: 'Singapore',
        isLocked: false,
        isPremium: false,
      ),
    ];
  }

  @override
  Future<Session> connect(int serverId) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: 30));
    
    return Session(
      id: 1,
      sessionId: 'mock-session-${now.millisecondsSinceEpoch}',
      userId: 1,
      serverId: serverId,
      poolId: 1,
      poolName: 'Default Pool',
      privateKey: 'mock-private-key',
      publicKey: 'mock-public-key',
      endpoint: '192.168.1.1',
      listenPort: 51820,
      ipAddress: '10.0.0.2',
      startTime: now.toIso8601String(),
      endTime: null,
      totalDuration: 0,
      status: 'active',
      createdAt: now.toIso8601String(),
      expiresAt: expiresAt.toIso8601String(),
    );
  }

  @override
  Future<bool> disconnect(String sessionId) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
} 