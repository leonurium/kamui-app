import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import '../blocs/server_list/server_list_bloc.dart';
import '../widgets/server_list_widget.dart';
import 'package:kamui_app/injection.dart' as di;

class ServerListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ServerListBloc>()..add(LoadServersEvent()),
      child: BlocListener<ServerListBloc, ServerListState>(
        listener: (context, state) {
          if (state is ServerListLoaded && state.selectedServer != null) {
            Navigator.of(context).pop(state.selectedServer);
          }
        },
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
              return WillPopScope(
                onWillPop: () async {
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
                          return ServerItemWidget(
                            isFaded: true,
                            label: server.location,
                            icon: Icons.lock,
                            flagAsset: _getFlagAsset(server.country),
                            pingResult: pingResult,
                            onTap: () {
                              context.read<ServerListBloc>().add(SelectServerEvent(server));
                            },
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
                                          backgroundImage: ExactAssetImage(
                                            _getFlagAsset(server.country),
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
                                        : Color.fromRGBO(37, 112, 252, 1),
                                    checkedColor: Color.fromRGBO(37, 112, 252, 1),
                                    isChecked: server == state.selectedServer,
                                    onTap: (x) {
                                      context.read<ServerListBloc>().add(SelectServerEvent(server));
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
      ),
    );
  }

  String _getFlagAsset(String country) {
    // Map country names to flag assets
    final flagAssets = {
      'England': 'assets/england.png',
      'United States': 'assets/usa.jpg',
      'Canada': 'assets/canada.png',
      'France': 'assets/france.png',
      'Ghana': 'assets/ghana.png',
    };
    return flagAssets[country] ?? 'assets/ghana.png'; // Default to Ghana flag if not found
  }
}
