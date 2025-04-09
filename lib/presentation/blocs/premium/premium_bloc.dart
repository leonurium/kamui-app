import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kamui_app/domain/entities/package.dart';
import 'package:kamui_app/domain/usecases/get_packages_usecase.dart';
import 'package:kamui_app/domain/usecases/purchase_package_usecase.dart';

part 'premium_event.dart';
part 'premium_state.dart';

class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final GetPackagesUseCase getPackagesUseCase;
  final PurchasePackageUseCase purchasePackageUseCase;

  PremiumBloc({
    required this.getPackagesUseCase,
    required this.purchasePackageUseCase,
  }) : super(PremiumInitial()) {
    on<LoadPackages>(_onLoadPackages);
    on<PurchasePackage>(_onPurchasePackage);
  }

  Future<void> _onLoadPackages(
    LoadPackages event,
    Emitter<PremiumState> emit,
  ) async {
    emit(PremiumLoading());
    try {
      final packages = await getPackagesUseCase.execute();
      emit(PremiumLoaded(packages));
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onPurchasePackage(
    PurchasePackage event,
    Emitter<PremiumState> emit,
  ) async {
    emit(PremiumLoading());
    try {
      final success = await purchasePackageUseCase.execute(
        event.packageId,
        event.purchaseToken,
        event.platform,
      );
      if (success) {
        emit(PremiumPurchaseSuccess());
        // Reload packages after successful purchase
        add(LoadPackages());
      } else {
        emit(PremiumError('Failed to purchase package'));
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }
} 