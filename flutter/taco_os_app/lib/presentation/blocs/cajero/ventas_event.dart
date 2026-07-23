import 'package:equatable/equatable.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/domain/entities/sale.dart';

/// Eventos del VentasBloc
///
/// Gestiona las acciones relacionadas con el flujo de registro de ventas:
/// selección de categoría, gestión del carrito, selección de método de pago,
/// confirmación de venta y cancelación con foto obligatoria.
///
/// **Validates: Requirements 5.1, 5.4, 5.5, 5.6, 5.9, 6.1, 6.2**
sealed class VentasEvent extends Equatable {
  const VentasEvent();

  @override
  List<Object?> get props => [];
}

/// Evento disparado cuando el cajero selecciona una categoría
///
/// Carga los productos de la categoría seleccionada desde Local_DB.
/// Si hay conectividad, sincroniza el catálogo en background.
///
/// **Validates: Requirements 5.1, 5.2, 5.3, 11.1**
class CategorySelected extends VentasEvent {
  final String businessId;
  final ProductCategory category;

  const CategorySelected({required this.businessId, required this.category});

  @override
  List<Object?> get props => [businessId, category];
}

/// Evento disparado cuando el cajero agrega un producto al carrito
///
/// Incluye el producto, la cantidad ingresada y calcula el subtotal.
/// Permite múltiples productos antes de confirmar la venta.
///
/// **Validates: Requirements 5.4, 5.5, 5.8**
class ProductAdded extends VentasEvent {
  final Product product;
  final int quantity;

  const ProductAdded({required this.product, required this.quantity});

  @override
  List<Object?> get props => [product, quantity];
}

/// Evento disparado cuando el cajero elimina un producto del carrito
///
/// Remueve el producto del carrito antes de confirmar la venta.
///
/// **Validates: Requirement 5.5**
class ProductRemoved extends VentasEvent {
  final String productId;

  const ProductRemoved({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// Evento disparado cuando el cajero selecciona el método de pago
///
/// Permite elegir entre efectivo (cash) o tarjeta (card) antes de confirmar.
///
/// **Validates: Requirement 5.6**
class PaymentMethodSelected extends VentasEvent {
  final PaymentMethod paymentMethod;

  const PaymentMethodSelected({required this.paymentMethod});

  @override
  List<Object?> get props => [paymentMethod];
}

/// Evento disparado cuando el cajero confirma la venta
///
/// Registra la venta en Local_DB con todos los productos del carrito,
/// método de pago seleccionado, y marca como is_synced = false.
///
/// **Validates: Requirements 5.6, 5.9, 10.1, 10.2**
class SaleConfirmed extends VentasEvent {
  final String sessionId;
  final String businessId;
  final String cashierId;

  const SaleConfirmed({
    required this.sessionId,
    required this.businessId,
    required this.cashierId,
  });

  @override
  List<Object?> get props => [sessionId, businessId, cashierId];
}

/// Evento disparado cuando el cajero solicita cancelar una venta
///
/// Verifica que la venta esté dentro de la ventana anti-fraude (< 5 min)
/// y activa la cámara para capturar la foto obligatoria.
///
/// **Validates: Requirements 6.1, 6.2, 6.3**
class SaleCancellationRequested extends VentasEvent {
  final String saleId;
  final DateTime saleTimestamp;

  const SaleCancellationRequested({
    required this.saleId,
    required this.saleTimestamp,
  });

  @override
  List<Object?> get props => [saleId, saleTimestamp];
}

/// Evento disparado cuando el cajero captura la foto de cancelación
///
/// Completa la cancelación de la venta con la foto obligatoria,
/// marca la venta como cancelada y revierte los totales del turno.
///
/// **Validates: Requirements 6.2, 6.4, 6.6**
class CancellationPhotoTaken extends VentasEvent {
  final String saleId;
  final String photoPath;
  final DateTime saleTimestamp;

  const CancellationPhotoTaken({
    required this.saleId,
    required this.photoPath,
    required this.saleTimestamp,
  });

  @override
  List<Object?> get props => [saleId, photoPath, saleTimestamp];
}
