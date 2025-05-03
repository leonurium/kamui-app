import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kamui_app/core/config/constants.dart';
import 'package:kamui_app/core/services/wireguard_service.dart';
import 'package:kamui_app/core/services/ping_service.dart';
import 'package:kamui_app/core/utils/connection_state_utils.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/domain/entities/device.dart';
import 'package:kamui_app/domain/usecases/get_servers_usecase.dart';
import 'package:kamui_app/presentation/screens/server_list_page.dart';
import 'package:kamui_app/presentation/screens/subscription_page.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart' as vpn;
import 'package:kamui_app/domain/entities/server.dart';
import 'package:kamui_app/presentation/widgets/ads_overlay_widget.dart';
import 'package:kamui_app/presentation/widgets/connection_button_widget.dart';
import 'package:kamui_app/presentation/widgets/banner_ad_widget.dart';
import 'package:kamui_app/presentation/blocs/ads/ads_bloc.dart';
import 'package:kamui_app/presentation/blocs/server_list/server_list_bloc.dart' as server_list;
import 'package:kamui_app/injection.dart' as di;
import 'package:kamui_app/presentation/blocs/timer/timer_bloc.dart' as timer;

import '../widgets/server_list_widget.dart';

class HomePage extends StatefulWidget {
  final vpn.VpnBloc vpnBloc;
  
  const HomePage({super.key, required this.vpnBloc});
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _showingAds = false;
  bool _isFirstLaunch = true;
  ConnectionData? currentConnectionData;
  Server? server;
  String connectionTime = '00.00.00';
  late String signature;
  final WireGuardService _wireguardService = WireGuardService();
  StreamSubscription? _vpnStateSubscription;
  VpnStage _currentStage = VpnStage.disconnected;
  late AdsBloc _adsBloc;
  late server_list.ServerListBloc _serverListBloc;
  late timer.TimerBloc _timerBloc;
  late SharedPreferences _prefs;
  bool _isPremium = false;
  String? _version;

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

  Future<void> _getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${packageInfo.version}';
    });
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
    WidgetsBinding.instance.addObserver(this);
    _adsBloc = AdsBloc();
    _adsBloc.add(LoadAdsEvent());
    _serverListBloc = server_list.ServerListBloc(
      di.sl<SharedPreferences>(),
      di.sl<GetServersUseCase>(),
      di.sl<PingService>(),
    );
    _timerBloc = timer.TimerBloc();
        
    if (!widget.vpnBloc.isClosed) {
      widget.vpnBloc.add(vpn.LoadServersEvent());
    }
    
    _initWireguard();
    _loadDeviceData().then((_) {
      _serverListBloc.add(server_list.LoadServersEvent());
    });
    _getVersion();
    
    if (_isFirstLaunch && !Constants.forceBlockAds && !_isPremium) {
      setState(() {
        _showingAds = true;
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      _checkWireguardStatus();
    });
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
    WidgetsBinding.instance.removeObserver(this);
    _vpnStateSubscription?.cancel();
    _adsBloc.close();
    _timerBloc.close();
    if (_currentStage == VpnStage.connected) {
      _wireguardService.disconnect();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Add a small delay to ensure the app is fully resumed
      Future.delayed(Duration(milliseconds: 500), () {
        _checkWireguardStatus();
      });
    }
  }

  Future<void> _checkWireguardStatus() async {
    try {
      final isConnected = await WireGuardFlutter.instance.isConnected();
      if (mounted) {
        setState(() {
          _currentStage = isConnected ? VpnStage.connected : VpnStage.disconnected;
          if (isConnected) {
            // If connected, ensure we have the connection data
            if (currentConnectionData == null) {
              // Try to get the current connection data from the bloc state
              final currentState = widget.vpnBloc.state;
              if (currentState is vpn.VpnConnected) {
                currentConnectionData = currentState.connectionData;
              }
            }
          } else {
            // If disconnected, clear connection data
            currentConnectionData = null;
          }
        });
        
        // Show status update to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isConnected ? 'VPN is connected' : 'VPN is disconnected',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: isConnected ? Colors.green : Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Logger.error('Failed to check WireGuard status: $e');
      if (mounted) {
        setState(() {
          _currentStage = VpnStage.disconnected;
          currentConnectionData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check VPN status: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleVpnConnection() {
    if (server == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a server first')),
      );
      return;
    }
    
    if (!mounted) return;
    
    // Stop any existing timer before starting new connection
    _timerBloc.add(timer.StopTimerEvent());
    
    setState(() {
      if (!Constants.forceBlockAds && !_isPremium) {
        _showingAds = true;
      } else {
        // If ads are blocked or user is premium, trigger VPN connection directly
        _onAdsClosed(); // This will handle the VPN connection
      }
    });
  }

  void _handleVpnDisconnection() {
    if (!mounted) return;
    
    // Stop the timer when disconnecting
    _timerBloc.add(timer.StopTimerEvent());
    
    setState(() {
      if (!Constants.forceBlockAds && !_isPremium) {
        _showingAds = true;
      } else {
        // If ads are blocked or user is premium, trigger VPN disconnection directly
        _onAdsClosed(); // This will handle the VPN disconnection
      }
    });
  }

  Future<void> _onAdsClosed() async {
    if (_isFirstLaunch) {
      setState(() {
        _showingAds = false;
        _isFirstLaunch = false;
      });
      return;
    }
    setState(() {
      _showingAds = false;
    });
    
    if (!mounted) return;

    // Check if bloc is closed
    if (widget.vpnBloc.isClosed) {
      return;
    }
    
    final isConnected = await _wireguardService.isConnected();
    
    if (!isConnected) {
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
        _currentStage = VpnStage.disconnecting;
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
        BlocProvider.value(value: _timerBloc),
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
                // Start the timer with fresh connection data and current time
                _timerBloc.add(timer.StartTimerEvent(
                  state.connectionData, 
                  _isPremium,
                  startTime: DateTime.now(),
                ));
              } else if (state is vpn.VpnDisconnected) {
                setState(() {
                  currentConnectionData = null;
                  _currentStage = VpnStage.disconnecting;
                });
                _wireguardService.disconnect();
                // Stop the timer
                _timerBloc.add(timer.StopTimerEvent());
              } else if (state is vpn.VpnError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                setState(() {
                  _currentStage = VpnStage.disconnected;
                });
                // Stop the timer
                _timerBloc.add(timer.StopTimerEvent());
              }
            },
            child: BlocListener<timer.TimerBloc, timer.TimerState>(
              bloc: _timerBloc,
              listener: (context, state) {
                if (state is timer.TimerRunning) {
                  if (state.shouldDisconnect && !_isPremium) {
                    // Auto disconnect for free users after 30 minutes
                    _handleVpnDisconnection();
                  }
                  if (state.shouldShowAds && !_isPremium) {
                    setState(() {
                      _showingAds = true;
                    });
                  }
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
                              BlocBuilder<timer.TimerBloc, timer.TimerState>(
                                bloc: _timerBloc,
                                builder: (context, state) {
                                  String duration = '00:00:00';
                                  if (state is timer.TimerRunning) {
                                    duration = state.duration;
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
                              flagURL: server?.flagURL ?? '',
                              label: server?.location ?? 'No sever selected',
                              icon: Icons.arrow_forward_ios,
                              isEnabled: _currentStage != VpnStage.connected,
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
                            if (!_isPremium && !Constants.forceBlockAds)
                              Expanded(
                                child: Center(
                                  child: const BannerAdWidget(),
                                ),
                              ),
                            const SizedBox(height: 16),
                            if (!_isPremium && !Constants.forceBlockAds)
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
                            SizedBox(height: 8),
                            if (_version != null) ...[
                              if (_isPremium) const Spacer(),
                              Text(
                                _version!,
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            SizedBox(height: 35),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_showingAds && !_isPremium && !Constants.forceBlockAds)
            AdsOverlay(
              onClose: _onAdsClosed,
            ),
        ],
      ),
    );
  }
}