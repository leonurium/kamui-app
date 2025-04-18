import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';  // Add this import for PlatformException
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kamui_app/core/config/constants.dart';
import 'package:kamui_app/core/services/wireguard_service.dart';
import 'package:kamui_app/core/services/ping_service.dart';
import 'package:kamui_app/core/utils/connection_state_utils.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/domain/entities/device.dart';
import 'package:kamui_app/domain/usecases/get_servers_usecase.dart';
import 'package:kamui_app/presentation/screens/server_list_page.dart';
import 'package:kamui_app/presentation/screens/premium_page.dart';
import 'package:kamui_app/presentation/screens/subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart' as vpn;
import 'package:kamui_app/domain/entities/server.dart';
import 'package:kamui_app/presentation/widgets/ads_overlay_widget.dart';
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';
import 'package:kamui_app/presentation/widgets/connection_button_widget.dart';
import 'package:kamui_app/presentation/widgets/banner_ad_widget.dart';
import 'package:kamui_app/presentation/blocs/ads/ads_bloc.dart';
import 'package:kamui_app/presentation/blocs/server_list/server_list_bloc.dart' as server_list;
import 'package:kamui_app/injection.dart' as di;

import '../widgets/server_list_widget.dart';

class HomePage extends StatefulWidget {
  final vpn.VpnBloc vpnBloc;
  
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
  final WireGuardService _wireguardService = WireGuardService();
  StreamSubscription? _vpnStateSubscription;
  VpnStage _currentStage = VpnStage.disconnected;
  late AdsBloc _adsBloc;
  late server_list.ServerListBloc _serverListBloc;
  late SharedPreferences _prefs;
  bool _isPremium = false;

  Future<void> _loadDeviceData() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final deviceDataJson = _prefs.getString('device_data');
      if (deviceDataJson != null) {
        final deviceData = Device.fromJson(jsonDecode(deviceDataJson));
        setState(() {
          _isPremium = deviceData.isPremium;
        });
      }
    } catch (e) {
      Logger.error('Failed to load device data: $e');
    }
  }

  void _selectDefaultServer(List<Server> servers) {
    if (servers.isEmpty) return;

    // Filter servers based on premium status
    final availableServers = servers.where((s) => s.isPremium == _isPremium).toList();
    if (availableServers.isEmpty) {
      // If no matching servers, fall back to any server
      availableServers.addAll(servers);
    }

    // Select the first available server
    setState(() {
      server = availableServers.first;
    });
  }

  @override
  void initState() {
    super.initState();
    _adsBloc = AdsBloc();
    _adsBloc.add(LoadAdsEvent());
    _serverListBloc = server_list.ServerListBloc(
      di.sl<SharedPreferences>(),
      di.sl<GetServersUseCase>(),
      di.sl<PingService>(),
    );
        
    if (!widget.vpnBloc.isClosed) {
      widget.vpnBloc.add(vpn.LoadServersEvent());
    }
    
    _initWireguard();
    _loadDeviceData().then((_) {
      // Load servers and select default based on premium status
      _serverListBloc.add(server_list.LoadServersEvent());
    });
    
    // Show ads on first launch only if forceBlockAds is false
    if (_isFirstLaunch && !Constants.forceBlockAds) {
      setState(() {
        _showingAds = true;
      });
    }
  }

  Future<void> _initWireguard() async {
    try {
      await _wireguardService.initialize();
      _vpnStateSubscription = WireGuardFlutter.instance.vpnStageSnapshot.listen(
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
    _adsBloc.close();
    if (_currentStage == VpnStage.connected) {
      _wireguardService.disconnect();
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
    
    setState(() {
      _isConnecting = true;  // Set connecting state before showing ads
      if (!Constants.forceBlockAds) {
        _showingAds = true;
      } else {
        // If ads are blocked, trigger VPN connection directly
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
      _isConnecting = false;
      if (!Constants.forceBlockAds) {
        _showingAds = true;
      } else {
        // If ads are blocked, trigger VPN disconnection directly
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

    // Check if bloc is closed
    if (widget.vpnBloc.isClosed) {
      return;
    }
    
    if (_isConnecting) {
      if (server != null) {
        _showLoadingSnackBar('Connecting to VPN...');
        widget.vpnBloc.add(vpn.ConnectVpnEvent(server!.id));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a server first')),
        );
      }
    } else {
      if (currentConnectionData != null) {
        _showLoadingSnackBar('Disconnecting from VPN...');
        widget.vpnBloc.add(vpn.DisconnectVpnEvent(
          sessionId: currentConnectionData!.session.sessionId,
          serverLocation: currentConnectionData!.session.serverId.toString(),
          protocol: currentConnectionData!.session.endpoint,
        ));
      }
    }
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.vpnBloc),
        BlocProvider.value(value: _adsBloc),
        BlocProvider.value(value: _serverListBloc),
      ],
      child: Stack(
        children: [
          BlocListener<vpn.VpnBloc, vpn.VpnState>(
            bloc: widget.vpnBloc,
            listener: (context, state) {
              if (state is vpn.VpnConnected) {
                setState(() {
                  currentConnectionData = state.connectionData;
                  _currentStage = VpnStage.connecting;
                });
                // Start WireGuard connection after successful API call
                _wireguardService.connect(state.connectionData);
              } else if (state is vpn.VpnDisconnected) {
                setState(() {
                  currentConnectionData = null;
                  _currentStage = VpnStage.disconnecting;
                });
                _wireguardService.disconnect();
              } else if (state is vpn.VpnError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                setState(() {
                  _currentStage = VpnStage.disconnected;
                });
              }
            },
            child: BlocListener<server_list.ServerListBloc, server_list.ServerListState>(
              bloc: _serverListBloc,
              listener: (context, state) {
                if (state is server_list.ServerListLoaded) {
                  _selectDefaultServer([...state.premiumServers, ...state.freeServers]);
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
                      child: Opacity(
                        opacity: .1,
                        child: Image.asset(
                          'assets/background.png',
                          fit: BoxFit.fill,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          SizedBox(height: 25),
                          FutureBuilder<List<NetworkInterface>>(
                            future: NetworkInterface.list(),
                            builder: (context, snapshot) {
                              final data = snapshot.data ?? [];
                              final ip = data.isEmpty ? '0.0.0.0' : data.first.addresses.first.address;
                              return Center(
                                child: Text(
                                  ip,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 15),
                          Center(
                            child: ConnectionButtonWidget(
                              currentStage: _currentStage,
                              onTap: () {
                                if (_currentStage == VpnStage.connected) {
                                  _handleVpnDisconnection();
                                } else {
                                  _handleVpnConnection();
                                }
                              },
                              buttonText: ConnectionStateUtils.getConnectionState(_currentStage),
                              buttonColor: ConnectionStateUtils.getConnectionColor(_currentStage),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              ConnectionStateUtils.getConnectionDescription(_currentStage),
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge!.color
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (_currentStage == VpnStage.connected)
                            BlocBuilder<vpn.VpnBloc, vpn.VpnState>(
                              bloc: widget.vpnBloc,
                              builder: (context, state) {
                                String duration = '00.00.00';
                                if (state is vpn.VpnConnected) {
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
                                      color: Theme.of(context).textTheme.bodyMedium!.color,
                                    ),
                                  ),
                                );
                              },
                            ),
                          SizedBox(height: 25),
                          ServerItemWidget(
                            isFaded: false,
                            flagAsset: 'assets/logo.png',
                            label: server?.location ?? 'No sever selected',
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
                          const SizedBox(height: 16),
                          const BannerAdWidget(),
                          Spacer(),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: MediaQuery.of(context).size.width / 4.5,
                              ),
                              backgroundColor: Color.fromARGB(255, 26, 48, 85),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SubscriptionPage(),
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
          ),
          if (_showingAds)
            AdsOverlay(
              onClose: _onAdsClosed,
            ),
        ],
      ),
    );
  }
}