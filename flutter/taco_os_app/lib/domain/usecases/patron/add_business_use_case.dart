import 'package:fpdart/fpdart.dart';
import '../../entities/business.dart';
import '../../repositories/i_business_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';

/// Parámetros para crear un nuevo negocio
class AddBusinessParams {
  final String name;
  final String ownerId;
  final SubscriptionPlan subscriptionPlan;

  const AddBusinessParams({
    required this.name,
    required this.ownerId,
    required this.subscriptionPlan,
  });
}

/// Caso de uso para agregar un negocio adicional al patrón
///
/// Valida que el patrón no exceda el límite de negocios de su plan
/// de suscripción antes de crear el negocio. Si el límite se alcanza,
/// retorna LicenseLimitFailure con el plan actual y un mensaje
/// informativo con CTA de upgrade.
///
/// Límites por plan:
/// - Free: 1 negocio
/// - Premium: 2 negocios
/// - Business: 5 negocios
///
/// Validada por Requirement 14.1: Límites de negocios según plan
/// Validada por Requirement 13.2: Use cases dependen de abstracciones
class AddBusinessUseCase implements UseCase<Business, AddBusinessParams> {
  final IBusinessRepository businessRepository;

  const AddBusinessUseCase(this.businessRepository);

  @override
  Future<Either<Failure, Business>> call(AddBusinessParams params) async {
    // 1. Obtener todos los negocios actuales del patrón
    final existingBusinessesResult = await businessRepository
        .getBusinessesByOwner(params.ownerId);

    return existingBusinessesResult.fold((failure) => left(failure), (
      existingBusinesses,
    ) async {
      // 2. Obtener el límite según el plan
      final limit = _getBusinessLimit(params.subscriptionPlan);

      // 3. Validar que no se exceda el límite
      if (existingBusinesses.length >= limit) {
        return left(
          LicenseLimitFailure(
            currentPlan: params.subscriptionPlan,
            message: _getLimitMessage(params.subscriptionPlan, limit),
          ),
        );
      }

      // 4. Crear el nuevo negocio
      final newBusiness = Business(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: params.name,
        ownerId: params.ownerId,
        subscriptionPlan: params.subscriptionPlan,
        createdAt: DateTime.now(),
      );

      return await businessRepository.createBusiness(newBusiness);
    });
  }

  /// Obtiene el límite de negocios según el plan de suscripción
  int _getBusinessLimit(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 1;
      case SubscriptionPlan.premium:
        return 2;
      case SubscriptionPlan.business:
        return 5;
    }
  }

  /// Genera el mensaje informativo cuando se alcanza el límite
  String _getLimitMessage(SubscriptionPlan currentPlan, int limit) {
    final planName = _getPlanName(currentPlan);
    final nextPlan = _getNextPlan(currentPlan);

    return 'Has alcanzado el límite de $limit negocio(s) del plan $planName. '
        'Actualiza a $nextPlan para agregar más negocios.';
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
