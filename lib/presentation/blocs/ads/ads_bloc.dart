import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
  final List<String> _adUrls = [
    'https://www.lipsum.com/images/banners/black_468x60.gif',
    'https://www.lipsum.com/images/banners/white_468x60.gif',
    'https://www.lipsum.com/images/banners/grey_468x60.gif',
  ];

  AdsBloc() : super(AdsInitial()) {
    on<LoadAdsEvent>((event, emit) {
      try {
        final randomIndex = DateTime.now().millisecondsSinceEpoch % _adUrls.length;
        final randomAdUrl = _adUrls[randomIndex];
        emit(AdsLoaded(currentAdUrl: randomAdUrl));
      } catch (e) {
        emit(AdsError('Failed to load ads: $e'));
      }
    });
  }
} 