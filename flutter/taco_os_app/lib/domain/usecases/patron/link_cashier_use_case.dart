import 'package:fpdart/fpdart.dart';
import '../../entities/business.dart';
import '../../repositories/i_business_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';

/// Parámetros para vincular un cajero a un negocio
class LinkCashierParams {
  final String cashierId;
  final String businessId;

  const LinkCashierParams({required this.cashierId, required this.businessId});
}

/// Caso de uso para vincular un cajero adicional al negocio
///
/// Valida que el negocio no exceda el límite de cajeros de su plan
/// de suscripción antes de vincular al cajero. Si el límite se alcanza,
/// retorna LicenseLimitFailure con el plan actual y un mensaje
/// informativo con CTA de upgrade.
///
/// Límites por plan:
/// - Free: 2 cajeros
/// - Premium: 5 cajeros
/// - Business: 25 cajeros
///
/// Validada por Requirement 14.2: Límites de cajeros según plan
/// Validada por Requirement 13.2: Use cases dependen de abstracciones
class LinkCashierUseCase implements UseCase<void, LinkCashierParams> {
  final IBusinessRepository businessRepository;

  const LinkCashierUseCase(this.businessRepository);

  @override
  Future<Either<Failure, void>> call(LinkCashierParams params) async {
    // 1. Obtener el negocio para conocer su plan de suscripción
    final businessResult = await businessRepository.getBusinessById(
      params.businessId,
    );

    return businessResult.fold((failure) => left(failure), (business) async {
      // 2. Obtener los cajeros actuales del negocio
      final cashiersResult = await businessRepository.getCashiersByBusiness(
        params.businessId,
      );

      return cashiersResult.fold((failure) => left(failure), (
        existingCashiers,
      ) async {
        // 3. Obtener el límite según el plan del negocio
        final limit = _getCashierLimit(business.subscriptionPlan);

        // 4. Validar que no se exceda el límite
        if (existingCashiers.length >= limit) {
          return left(
            LicenseLimitFailure(
              currentPlan: business.subscriptionPlan,
              message: _getLimitMessage(business.subscriptionPlan, limit),
            ),
          );
        }

        // 5. Vincular el cajero al negocio
        return await businessRepository.linkCashierToBusiness(
          cashierId: params.cashierId,
          businessId: params.businessId,
        );
      });
    });
  }

  /// Obtiene el límite de cajeros según el plan de suscripción
  int _getCashierLimit(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 2;
      case SubscriptionPlan.premium:
        return 5;
      case SubscriptionPlan.business:
        return 25;
    }
  }

  /// Genera el mensaje informativo cuando se alcanza el límite
  String _getLimitMessage(SubscriptionPlan currentPlan, int limit) {
    final planName = _getPlanName(currentPlan);
    final nextPlan = _getNextPlan(currentPlan);

    return 'Has alcanzado el límite de $limit cajero(s) del plan $planName. '
        'Actualiza a $nextPlan para vincular más cajeros.';
  }

  String _getPlanName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.business:
        return 'Business';
    }
  }

  String _getNextPlan(SubscriptionPlan currentPlan) {
    switch (currentPlan) {
      case SubscriptionPlan.free:
        return 'Premium';
      case SubscriptionPlan.premium:
        return 'Business';
      case SubscriptionPlan.business:
        return 'Enterprise'; // o mantener como Business
    }
  }
}
