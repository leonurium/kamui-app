import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import '../blocs/server_list/server_list_bloc.dart';
import 'package:kamui_app/domain/entities/server.dart';

class ServerListPage extends StatefulWidget {
  final Server? selectedServer;
  final ServerListBloc bloc;
  final bool isPremium;
  
  const ServerListPage({
    super.key, 
    this.selectedServer,
    required this.bloc,
    required this.isPremium,
  });

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  @override
  void initState() {
    super.initState();
    // Load servers if not already loaded
    if (widget.bloc.state is! ServerListLoaded) {
      widget.bloc.add(LoadServersEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<ServerListBloc, ServerListState>(
        builder: (context, state) {
          if (state is ServerListLoading) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Servers',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ServerListError) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Servers',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              body: Center(child: Text(state.message)),
            );
          }

          if (state is ServerListLoaded) {
            // Start ping timer if not already started
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.bloc.add(StartPingTimerEvent());
            });

            return WillPopScope(
              onWillPop: () async {
                widget.bloc.add(StopPingTimerEvent());
                Navigator.of(context).pop(state.selectedServer);
                return true;
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Servers',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                body: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(20),
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Premium ',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
                        children: [
                          TextSpan(
                            text: 'Servers',
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.normal)
                          )
                        ]
                      )
                    ),
                    SizedBox(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.premiumServers.length,
                      itemBuilder: (_, index) {
                        final server = state.premiumServers[index];
                        final pingResult = state.pingResults[server.id];
                        return Material(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.white,
                                        child: ClipOval(
                                          child: Image.network(
                                            server.flagURL,
                                            width: 30,
                                            height: 30,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(Icons.flag, size: 20, color: Colors.grey);
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            server.location,
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                          if (pingResult != null)
                                            Text(
                                              '${pingResult.mbps.toStringAsFixed(1)} Mbps • ${pingResult.latency}ms',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: pingResult.isOnline ? Colors.green : Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.isPremium)
                                  RoundCheckBox(
                                    size: 24,
                                    checkedWidget: const Icon(Icons.check, size: 18, color: Colors.white),
                                    borderColor: server == state.selectedServer
                                        ? Theme.of(context).scaffoldBackgroundColor
                                        : Color.fromARGB(255, 26, 48, 85),
                                    checkedColor: Color.fromARGB(255, 26, 48, 85),
                                    isChecked: server == state.selectedServer,
                                    onTap: (x) {
                                      widget.bloc.add(SelectServerEvent(server));
                                      Navigator.of(context).pop(server);
                                    },
                                  )
                                else
                                  Icon(
                                    Icons.lock,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, index) => SizedBox(height: 10),
                    ),
                    SizedBox(height: 30),
                    RichText(
                      text: TextSpan(
                        text: 'Free ',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
                        children: [
                          TextSpan(
                            text: 'Servers',
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.normal)
                          )
                        ]
                      )
                    ),
                    SizedBox(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.freeServers.length,
                      itemBuilder: (_, index) {
                        final server = state.freeServers[index];
                        final pingResult = state.pingResults[server.id];
                        return Material(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.white,
                                        child: ClipOval(
                                          child: Image.network(
                                            server.flagURL,
                                            width: 30,
                                            height: 30,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(Icons.flag, size: 20, color: Colors.grey);
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            server.location,
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                          if (pingResult != null)
                                            Text(
                                              '${pingResult.mbps.toStringAsFixed(1)} Mbps • ${pingResult.latency}ms',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: pingResult.isOnline ? Colors.green : Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                RoundCheckBox(
                                  size: 24,
                                  checkedWidget: const Icon(Icons.check, size: 18, color: Colors.white),
                                  borderColor: server == state.selectedServer
                                      ? Theme.of(context).scaffoldBackgroundColor
                                      : Color.fromARGB(255, 26, 48, 85),
                                  checkedColor: Color.fromARGB(255, 26, 48, 85),
                                  isChecked: server == state.selectedServer,
                                  onTap: (x) {
                                    widget.bloc.add(SelectServerEvent(server));
                                    Navigator.of(context).pop(server);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, index) => SizedBox(height: 10),
                    ),
                  ],
                ),
              ),
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}
