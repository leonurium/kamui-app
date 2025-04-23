import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:kamui_app/domain/entities/ad.dart';

// Events
abstract class AdsEvent extends Equatable {
  const AdsEvent();

  @override
  List<Object> get props => [];
}

class LoadAdsEvent extends AdsEvent {}

// States
abstract class AdsState extends Equatable {
  const AdsState();

  @override
  List<Object> get props => [];
}

class AdsInitial extends AdsState {}

class AdsLoaded extends AdsState {
  final String currentAdUrl;
  final bool isVisible;

  const AdsLoaded({
    required this.currentAdUrl,
    this.isVisible = true,
  });

  @override
  List<Object> get props => [currentAdUrl, isVisible];
}

class AdsError extends AdsState {
  final String message;

  const AdsError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class AdsBloc extends Bloc<AdsEvent, AdsState> {
  AdsBloc() : super(AdsInitial()) {
    on<LoadAdsEvent>((event, emit) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final adsJson = prefs.getString('ads_banner');
        
        if (adsJson != null) {
          final List<dynamic> adsList = jsonDecode(adsJson);
          if (adsList.isNotEmpty) {
            final ads = adsList.map((ad) => Ad.fromJson(ad)).toList();
            // Get a random ad from the list
            final randomIndex = DateTime.now().millisecondsSinceEpoch % ads.length;
            final randomAd = ads[randomIndex];
            emit(AdsLoaded(currentAdUrl: randomAd.mediaUrl));
          } else {
            emit(AdsError('No banner ads available'));
          }
        } else {
          emit(AdsError('No banner ads data found'));
        }
      } catch (e) {
        emit(AdsError('Failed to load ads: $e'));
      }
    });
  }
} 