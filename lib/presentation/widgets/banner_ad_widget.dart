import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/presentation/blocs/ads/ads_bloc.dart';
import 'package:kamui_app/core/config/constants.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If ads are blocked, return empty widget
    if (Constants.forceBlockAds) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<AdsBloc, AdsState>(
      builder: (context, state) {
        if (state is AdsLoaded && state.isVisible) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // Use the minimum of available width or height to maintain square
              final size = constraints.maxWidth < constraints.maxHeight 
                  ? constraints.maxWidth 
                  : constraints.maxHeight;
              
              return SizedBox(
                width: size,
                height: size,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            state.currentAdUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error_outline, color: Colors.red),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () {
                            context.read<AdsBloc>().add(LoadAdsEvent());
                          },
                          child: const Icon(
                            Icons.refresh,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (state is AdsError) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth < constraints.maxHeight 
                  ? constraints.maxWidth 
                  : constraints.maxHeight;
              
              return SizedBox(
                width: size,
                height: size,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
} 