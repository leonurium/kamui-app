import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';  // Add this import for PlatformException

import 'package:avatar_glow/avatar_glow.dart';
import 'package:kamui_app/core/config/constants.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/presentation/screens/server_list_page.dart';
import 'package:kamui_app/presentation/screens/premium_page.dart';
import 'package:flutter/material.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart';
import 'package:kamui_app/domain/entities/server.dart';
import 'package:kamui_app/domain/entities/session.dart';
import 'package:kamui_app/presentation/widgets/ads_overlay_widget.dart';
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kamui_app/injection.dart' as di;

import '../widgets/server_list_widget.dart';

class HomePage extends StatefulWidget {
  final VpnBloc vpnBloc;
  
  const HomePage({Key? key, required this.vpnBloc}) : super(key: key);
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showingAds = false;
  bool _isFirstLaunch = true;
  ConnectionData? currentConnectionData;
  Server? server;
  String connectionTime = '00.00.00';
  late String signature;
  bool _isConnecting = false;
  final WireGuardFlutterInterface _wireguard = WireGuardFlutter.instance;
  StreamSubscription? _vpnStateSubscription;
  VpnStage _currentStage = VpnStage.disconnected;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    Logger.info('HomePage: Initializing with VpnBloc: ${widget.vpnBloc}');
    
    // Get SharedPreferences instance from GetIt
    _prefs = di.sl<SharedPreferences>();
    
    if (!widget.vpnBloc.isClosed) {
      widget.vpnBloc.add(LoadServersEvent());
    } else {
      Logger.error('HomePage: VpnBloc is closed during initialization');
    }
    
    _initWireguard();
    // Show ads on first launch only if forceBlockAds is false
    if (_isFirstLaunch && !Constants.forceBlockAds) {
      setState(() {
        _showingAds = true;
      });
    }
  }

  Future<void> _initWireguard() async {
    try {
      Logger.info('Initializing WireGuard VPN...');
      
      // Try to initialize WireGuard
      await _wireguard.initialize(interfaceName: "wg0");
      Logger.info('WireGuard VPN initialized successfully');
      
      _vpnStateSubscription = _wireguard.vpnStageSnapshot.listen(
        (stage) {
          Logger.info('VPN Stage changed to: $stage');
          if (mounted) {
            setState(() {
              _currentStage = stage;
            });
          }
        },
        onError: (error) {
          Logger.error('Error in VPN stage listener: $error');
          if (mounted) {
            setState(() {
              _currentStage = VpnStage.disconnected;
            });
          }
        },
      );
    } catch (e) {
      Logger.error('Failed to initialize WireGuard VPN: $e');
      if (mounted) {
        setState(() {
          _currentStage = VpnStage.disconnected;
        });
      }
      // Show error to user if it's not an IPC error
      if (!e.toString().contains('IPC failed')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize VPN: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _vpnStateSubscription?.cancel();
    if (_currentStage == VpnStage.connected) {
      _disconnectWireguard();
    }
    super.dispose();
  }

  void _handleVpnConnection() {
    if (server == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a server first')),
      );
      return;
    }
    
    if (!mounted) return;

    Logger.info('on _handleVpnConnection');
    
    setState(() {
      if (!Constants.forceBlockAds) {
        _showingAds = true;
      } else {
        // If ads are blocked, trigger VPN connection directly
        _isConnecting = true;
        _onAdsClosed(); // This will handle the VPN connection
      }
    });
  }

  void _handleVpnDisconnection() {
    if (currentConnectionData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No active connection to disconnect')),
      );
      return;
    }
    
    if (!mounted) return;
    
    setState(() {
      if (!Constants.forceBlockAds) {
        _showingAds = true;
      } else {
        // If ads are blocked, trigger VPN disconnection directly
        _isConnecting = false;
        _onAdsClosed(); // This will handle the VPN disconnection
      }
    });
  }

  void _onAdsClosed() {
    setState(() {
      _showingAds = false;
      _isFirstLaunch = false;
    });
    
    if (!mounted) return;

    Logger.info('HomePage: Ads closed, current VpnBloc: ${widget.vpnBloc}');
    
    // Check if bloc is closed
    if (widget.vpnBloc.isClosed) {
      Logger.error('HomePage: VpnBloc is closed, cannot add events');
      return;
    }
    
    if (_isConnecting) {
      if (server != null) {
        Logger.info('HomePage: Connecting to VPN with server: $server');
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Connecting to VPN...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Add connect event to bloc
        widget.vpnBloc.add(ConnectVpnEvent(server!.id));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a server first')),
        );
      }
    } else {
      if (currentConnectionData != null) {
        Logger.info('HomePage: Disconnecting from VPN with session: $currentConnectionData');
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Disconnecting from VPN...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Add disconnect event to bloc
        widget.vpnBloc.add(DisconnectVpnEvent(
          sessionId: currentConnectionData!.session.sessionId,
          serverLocation: currentConnectionData!.session.serverId.toString(),
          protocol: currentConnectionData!.session.endpoint));
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('No active connection to disconnect')),
        // );
      }
    }
  }

  Future<bool> _checkVpnPermission() async {
    try {
      // We can't directly check VPN permission status, but we can try to initialize
      // which will fail if permission is not granted
      await _wireguard.initialize(interfaceName: "wg0");
      return true;
    } catch (e) {
      Logger.error('Error checking VPN permission: $e');
      return false;
    }
  }

  Future<void> _connectWireguard(ConnectionData connectionData) async {
    // Check VPN permission first
    final hasPermission = await _checkVpnPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('VPN permission is required to connect. Please grant permission when prompted.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      // Save session data to SharedPreferences
      final sessionJson = jsonEncode(connectionData.toJson());
      await _prefs.setString('current_connection_data', sessionJson);
      Logger.info('Current Connection data saved to SharedPreferences');

      String config = '[Interface]';
      config += '\nPrivateKey = ${connectionData.session.privateKey}';
      config += '\nAddress = ${connectionData.session.ipAddress}';
      config += '\nDNS = ${connectionData.pool.dns}';
      config += '\n[Peer]';
      config += '\nPublicKey = ${connectionData.session.publicKey}';
      
      config += '\nAllowedIPs = ${connectionData.pool.allowedIps}';
      config += '\nPersistentKeepalive = ${connectionData.pool.persistentKeepalive}';
      config += '\nEndpoint = ${connectionData.session.endpoint}:${connectionData.session.listenPort}';

      if (connectionData.pool.presharedKey.trim().isNotEmpty) {
        config += '\nPresharedKey = ${connectionData.pool.presharedKey}';
      }

      Logger.info('Starting WireGuard VPN with config: $config');
      
      // Show loading indicator while waiting for permission
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Requesting VPN permission...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      await _wireguard.startVpn(
        serverAddress: connectionData.session.endpoint,
        wgQuickConfig: config,
        providerBundleIdentifier: 'com.gamavpn.app',
      );
      
      setState(() {
        _currentStage = VpnStage.connected;
      });
      
      Logger.info('WireGuard VPN started successfully');
    } catch (e) {
      Logger.error('WireGuard connection error: $e');
      Logger.error('Error type: ${e.runtimeType}');
      Logger.error('Error stack trace: ${StackTrace.current}');
      
      if (Constants.isUseMockData) {
        // If using mock data, simulate successful connection
        setState(() {
          _currentStage = VpnStage.connected;
        });
      } else {
        if (mounted) {
          String errorMessage = 'Failed to connect to VPN';
          
          // Add more detailed error information
          if (e is PlatformException) {
            errorMessage += '\nCode: ${e.code}';
            errorMessage += '\nMessage: ${e.message}';
            errorMessage += '\nDetails: ${e.details}';
          } else {
            errorMessage += '\nError: $e';
          }
          Logger.error('Error message: $errorMessage');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
        setState(() {
          _currentStage = VpnStage.disconnected;
        });
      }
    }
  }

  Future<void> _disconnectWireguard() async {
    Logger.warning("hello world");
    try {
      // Get session data from SharedPreferences
      final sessionJson = _prefs.getString('current_session');
      
      if (sessionJson != null) {
        try {
          // Parse session data first
          final sessionData = jsonDecode(sessionJson);
          final session = Session.fromJson(sessionData);
          
          // Stop VPN
          await _wireguard.stopVpn();
          setState(() {
            _currentStage = VpnStage.disconnected;
          });
          
          // Add disconnect event to bloc with session ID
          widget.vpnBloc.add(DisconnectVpnEvent(
            sessionId: session.sessionId,
            serverLocation: session.serverId.toString(),
            protocol: session.endpoint));
          
          // Clear session data from SharedPreferences
          await _prefs.remove('current_session');
          Logger.info('Session data cleared from SharedPreferences');
        } catch (e) {
          Logger.error('Error parsing session data: $e');
          // Clear invalid session data
          await _prefs.remove('current_session');
          // Still try to stop VPN even if session data is invalid
          await _wireguard.stopVpn();
          setState(() {
            _currentStage = VpnStage.disconnected;
          });
        }
      } else {
        Logger.info('No session data found, stopping VPN directly');
        // Stop VPN if no session data
        await _wireguard.stopVpn();
        setState(() {
          _currentStage = VpnStage.disconnected;
        });
      }
    } catch (e) {
      Logger.error('WireGuard disconnection error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to disconnect from VPN: $e')),
      );
      setState(() {
        _currentStage = VpnStage.disconnected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocListener<VpnBloc, VpnState>(
          bloc: widget.vpnBloc,
          listener: (context, state) {
            if (state is VpnConnected) {
              setState(() {
                currentConnectionData = state.connectionData;
                _currentStage = VpnStage.connecting;
              });
              // Start WireGuard connection after successful API call
              _connectWireguard(state.connectionData);
            } else if (state is VpnDisconnected) {
              setState(() {
                currentConnectionData = null;
                _currentStage = VpnStage.disconnecting;
              });
              _disconnectWireguard();
            } else if (state is VpnError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              setState(() {
                _currentStage = VpnStage.disconnected;
              });
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Gama VPN',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              leading: Image.asset(
                'assets/logo.png',
                width: 35,
                height: 35,
              ),
            ),
            body: Stack(
              children: [
                Positioned(
                  top: 50,
                  child: Opacity(
                    opacity: .1,
                    child: Image.asset(
                      'assets/background.png',
                      fit: BoxFit.fill,
                      height: MediaQuery.of(context).size.height / 1.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      SizedBox(height: 25),
                      Center(
                        child: Text(
                          '${connectionState(state: _currentStage)}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      SizedBox(height: 8),
                      FutureBuilder<List<NetworkInterface>>(
                        future: NetworkInterface.list(),
                        builder: (context, snapshot) {
                          final data = snapshot.data ?? [];
                          final ip = data.isEmpty ? '0.0.0.0' : data.first.addresses.first.address;
                          return Center(
                            child: Text(
                              ip,
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: connectionColorState(state: _currentStage),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      Center(
                        child: InkWell(
                          onTap: () {
                            if (_currentStage == VpnStage.connected) {
                              _handleVpnDisconnection();
                            } else {
                              _handleVpnConnection();
                            }
                          },
                          borderRadius: BorderRadius.circular(90),
                          child: AvatarGlow(
                            glowColor: _currentStage != VpnStage.connected
                                ? Colors.transparent
                                : connectionColorState(state: _currentStage),
                            endRadius: 100.0,
                            duration: Duration(milliseconds: 2000),
                            repeat: _currentStage != VpnStage.connected ? false : true,
                            showTwoGlows: true,
                            repeatPauseDuration: Duration(milliseconds: 100),
                            shape: BoxShape.circle,
                            child: Material(
                              elevation: 0,
                              shape: CircleBorder(),
                              color: connectionColorState(state: _currentStage),
                              child: SizedBox(
                                height: 150,
                                width: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.power_settings_new,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '${connectionButtonState(state: _currentStage)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          connectionDescription(state: _currentStage),
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: _currentStage == VpnStage.connected 
                              ? Color.fromRGBO(37, 112, 252, 1)
                              : Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_currentStage == VpnStage.connected)
                        BlocBuilder<VpnBloc, VpnState>(
                          bloc: widget.vpnBloc,
                          builder: (context, state) {
                            String duration = '00.00.00';
                            if (state is VpnConnected) {
                              final startTime = DateTime.parse(state.connectionData.session.startTime);
                              final now = DateTime.now();
                              final diff = now.difference(startTime);
                              duration = "${diff.inHours.toString().padLeft(2, '0')}.${(diff.inMinutes % 60).toString().padLeft(2, '0')}.${(diff.inSeconds % 60).toString().padLeft(2, '0')}";
                            }
                            return Center(
                              child: Text(
                                duration,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Color.fromRGBO(37, 112, 252, 1),
                                ),
                              ),
                            );
                          },
                        ),
                      SizedBox(height: 25),
                      ServerItemWidget(
                        flagAsset: 'assets/logo.png',
                        label: server?.country ?? 'No sever selected',
                        icon: Icons.arrow_forward_ios,
                        onTap: () async {
                          final res = await Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ServerListPage();
                          }));

                          if (res != null) {
                            setState(() {
                              server = res;
                            });
                          }
                        },
                      ),
                      Spacer(),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: MediaQuery.of(context).size.width / 4.5,
                          ),
                          backgroundColor: Color.fromRGBO(37, 112, 252, 1),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PremiumPage(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Get Premium',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 35),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showingAds)
          AdsOverlay(
            onClose: _onAdsClosed,
          ),
      ],
    );
  }

  String connectionState({VpnStage? state}) {
    switch (state) {
      case VpnStage.connected:
        return 'Connected';
      case VpnStage.connecting:
        return 'Connecting';
      case VpnStage.disconnected:
        return 'Disconnected';
      case VpnStage.disconnecting:
        return 'Disconnecting';
      case VpnStage.denied:
        return 'Denied';
      case VpnStage.authenticating:
        return 'Authenticating';
      case VpnStage.exiting:
        return 'Exiting';
      case VpnStage.noConnection:
        return 'No Connection';
      case VpnStage.preparing:
        return 'Preparing';
      case VpnStage.reconnect:
        return 'Reconnecting';
      case VpnStage.waitingConnection:
        return 'Waiting Connection';
      default:
        return 'Getting connection status';
    }
  }

  String connectionButtonState({VpnStage? state}) {
    switch (state) {
      case VpnStage.connected:
        return 'Connected';
      case VpnStage.connecting:
        return 'Connecting';
      case VpnStage.disconnected:
        return 'Disconnected';
      case VpnStage.disconnecting:
        return 'Disconnecting';
      case VpnStage.denied:
        return 'Denied';
      case VpnStage.authenticating:
        return 'Authenticating';
      case VpnStage.exiting:
        return 'Exiting';
      case VpnStage.noConnection:
        return 'No Connection';
      case VpnStage.preparing:
        return 'Preparing';
      case VpnStage.reconnect:
        return 'Reconnecting';
      case VpnStage.waitingConnection:
        return 'Waiting Connection';
      default:
        return 'Getting connection status';
    }
  }

  String connectionDescription({VpnStage? state}) {
    switch (state) {
      case VpnStage.connected:
        return 'Your Internet is private';
      case VpnStage.disconnected:
        return 'Your Internet is not private';
      default:
        return '';
    }
  }

  Color connectionColorState({VpnStage? state}) {
    switch (state) {
      case VpnStage.connected:
        return Color.fromRGBO(37, 112, 252, 1);
      default:
        return Colors.grey;
    }
  }
}