import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kamui_app/injection.dart' as di;

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SharedPreferences _prefs;

  OnboardingBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  void _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      final hasCompletedOnboarding = _prefs.getBool('has_completed_onboarding') ?? false;
      if (hasCompletedOnboarding) {
        emit(OnboardingCompleted());
      } else {
        emit(OnboardingNotCompleted());
      }
    } catch (e) {
      emit(OnboardingError('Failed to check onboarding status'));
    }
  }

  void _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      await _prefs.setBool('has_completed_onboarding', true);
      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError('Failed to complete onboarding'));
    }
  }
} 