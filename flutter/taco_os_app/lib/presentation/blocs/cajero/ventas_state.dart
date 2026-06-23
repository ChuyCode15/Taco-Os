import 'package:equatable/equatable.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/entities/sale_item.dart';

/// Estados del VentasBloc
///
/// Representa el flujo completo de registro de ventas: selección de categoría,
/// listado de productos, gestión del carrito, selección de método de pago,
/// confirmación de venta, y cancelación con foto obligatoria.
///
/// **Validates: Requirements 5.1, 5.4, 5.5, 5.6, 5.9, 6.1, 6.2**
sealed class VentasState extends Equatable {
  const VentasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de seleccionar una categoría
///
/// La aplicación muestra las tres categorías fijas: Comida, Bebidas, Postres.
///
/// **Validates: Requirement 5.1**
class VentasInitial extends VentasState {
  const VentasInitial();
}

/// Estado de vista de categorías
///
/// Muestra las tres categorías fijas disponibles para selección.
/// Después de cargar productos, el estado cambia a [ProductListView].
///
/// **Validates: Requirement 5.1**
class CategoryView extends VentasState {
  const CategoryView();
}

/// Estado de vista de productos de una categoría
///
/// Muestra los productos de la categoría seleccionada desde Local_DB.
/// Los productos están filtrados por business_id para aislamiento multi-tenant.
///
/// **Validates: Requirements 5.2, 5.3, 11.1, 15.2**
class ProductListView extends VentasState {
  final ProductCategory category;
  final List<Product> products;

  const ProductListView({required this.category, required this.products});

  @override
  List<Object?> get props => [category, products];
}

/// Estado de vista del carrito con productos agregados
///
/// Muestra los productos agregados antes de confirmar la venta.
/// Permite agregar más productos, eliminar productos, o continuar al pago.
///
/// **Validates: Requirements 5.4, 5.5**
class CartView extends VentasState {
  final List<SaleItem> cartItems;
  final double total;

  const CartView({required this.cartItems, required this.total});

  @override
  List<Object?> get props => [cartItems, total];
}

/// Estado de vista de selección de método de pago
///
/// Muestra las opciones de pago: efectivo (cash) o tarjeta (card).
/// Después de seleccionar, confirma la venta con [SaleConfirmed].
///
/// **Validates: Requirement 5.6**
class PaymentView extends VentasState {
  final List<SaleItem> cartItems;
  final double total;

  const PaymentView({required this.cartItems, required this.total});

  @override
  List<Object?> get props => [cartItems, total];
}

/// Estado de carga durante operaciones asíncronas
///
/// Se emite mientras se cargan productos, se registra una venta,
/// o se procesa una cancelación.
class VentasLoading extends VentasState {
  const VentasLoading();
}

/// Estado de venta registrada exitosamente
///
/// Muestra la confirmación de venta con el ticket digital.
/// Limpia el carrito y permite regresar al Modo_Cajero.
///
/// **Validates: Requirements 5.6, 5.9, 10.1**
class SaleSuccess extends VentasState {
  final Sale sale;

  const SaleSuccess({required this.sale});

  @override
  List<Object?> get props => [sale];
}

/// Estado de error durante el registro de venta
///
/// Muestra el mensaje de error al usuario sin limpiar el carrito.
/// Permite al cajero reintentar la operación.
///
/// **Validates: Requirements 5.7 (error handling)**
class SaleError extends VentasState {
  final String message;

  const SaleError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de vista de cancelación de venta
///
/// Activa la cámara para capturar la foto obligatoria de cancelación.
/// Solo se activa si la venta está dentro de la ventana anti-fraude (< 5 min).
///
/// **Validates: Requirements 6.1, 6.2, 6.3**
class CancellationView extends VentasState {
  final String saleId;
  final DateTime saleTimestamp;

  const CancellationView({required this.saleId, required this.saleTimestamp});

  @override
  List<Object?> get props => [saleId, saleTimestamp];
}

/// Estado de cancelación de venta exitosa
///
/// Muestra la confirmación de cancelación con la foto asociada.
/// La venta queda marcada como cancelada y los totales del turno se revierten.
///
/// **Validates: Requirements 6.4, 6.7**
class CancellationSuccess extends VentasState {
  final Sale cancelledSale;

  const CancellationSuccess({required this.cancelledSale});

  @override
  List<Object?> get props => [cancelledSale];
}

/// Estado de error específico durante cancelación de venta
///
/// Muestra mensajes de error específicos de cancelación:
/// - Ventana anti-fraude expirada (≥ 5 minutos)
/// - Cámara no disponible
/// - Error al capturar foto obligatoria
///
/// **Validates: Requirements 6.3, 6.5**
class CancellationError extends VentasState {
  final String message;

  const CancellationError({required this.message});

  @override
  List<Object?> get props => [message];
}
