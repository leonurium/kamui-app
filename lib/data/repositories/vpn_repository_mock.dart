import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/domain/entities/pool.dart';
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
        location: 'New York',
        isLocked: false,
        isPremium: false,
        flagURL: 'https://flagcdn.com/w40/us.png',
        name: 'United States',
        countryCode: 'US',
      ),
      Server(
        id: 2,
        apiUrl: 'https://uk-server.example.com',
        country: 'United Kingdom',
        city: 'London',
        location: 'London',
        isLocked: false,
        isPremium: true,
        flagURL: 'https://flagcdn.com/w40/gb.png',
        name: 'United Kingdom',
        countryCode: 'GB',
      ),
      Server(
        id: 3,
        apiUrl: 'https://jp-server.example.com',
        country: 'Japan',
        city: 'Tokyo',
        location: 'Tokyo',
        isLocked: false,
        isPremium: true,
        flagURL: 'https://flagcdn.com/w40/jp.png',
        name: 'Japan',
        countryCode: 'JP',
      ),
      Server(
        id: 4,
        apiUrl: 'https://sg-server.example.com',
        country: 'Singapore',
        city: 'Singapore',
        location: 'Singapore',
        isLocked: false,
        isPremium: false,
        flagURL: 'https://flagcdn.com/w40/sg.png',
        name: 'Singapore',
        countryCode: 'SG',
      ),
    ];
  }

  @override
  Future<ConnectionData> connect(int serverId) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    
    final now = DateTime.now();
    final expiresAt = now.add(Duration(minutes: 30));
    
    return ConnectionData(
      pool: Pool(
        id: 5,
        name: 'utun00',
        serverId: serverId,
        publicKey: 'mock-public-key',
        endpoint: '13.212.59.212',
        persistentKeepalive: 25,
        allowedIps: '0.0.0.0/0, ::/0',
        presharedKey: '',
        dns: '1.1.1.1',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      session: Session(
        id: 0,
        sessionId: 'mock-session-${now.millisecondsSinceEpoch}',
        userId: 10,
        serverId: serverId,
        poolId: 5,
        poolName: 'utun00',
        privateKey: 'mock-private-key',
        publicKey: 'mock-public-key',
        endpoint: '13.212.59.212',
        listenPort: 51820,
        ipAddress: '10.0.0.146/32',
        startTime: now.toIso8601String(),
        endTime: null,
        lastActivity: now.toIso8601String(),
        totalDuration: 0,
        status: 'active',
        createdAt: '0001-01-01T00:00:00Z',
        expiresAt: expiresAt.toIso8601String(),
      ),
    );
  }

  @override
  Future<bool> disconnect(String sessionId) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
} 