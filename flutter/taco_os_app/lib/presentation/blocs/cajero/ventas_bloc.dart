import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/entities/sale_item.dart';
import 'package:taco_os_app/domain/usecases/cajero/cancel_sale_use_case.dart';
import 'package:taco_os_app/domain/usecases/cajero/register_sale_use_case.dart';
import 'package:taco_os_app/domain/usecases/catalog/get_products_by_category_use_case.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_state.dart';
import 'package:uuid/uuid.dart';

/// BLoC para gestionar el flujo completo de registro de ventas en el Modo_Cajero
///
/// Maneja la selección de categorías, productos, gestión del carrito,
/// selección de método de pago, confirmación de venta, y cancelación
/// con foto obligatoria dentro de la ventana anti-fraude.
///
/// **Estados:**
/// - [VentasInitial]: Estado inicial sin categoría seleccionada
/// - [CategoryView]: Vista de las tres categorías fijas
/// - [ProductListView]: Lista de productos de una categoría
/// - [CartView]: Carrito con productos agregados antes de confirmar
/// - [PaymentView]: Selección de método de pago (efectivo o tarjeta)
/// - [VentasLoading]: Operación en progreso
/// - [SaleSuccess]: Venta registrada exitosamente
/// - [SaleError]: Error en operación de venta
/// - [CancellationView]: Vista para capturar foto de cancelación
/// - [CancellationSuccess]: Venta cancelada exitosamente
///
/// **Eventos:**
/// - [CategorySelected]: Carga productos de una categoría
/// - [ProductAdded]: Agrega producto al carrito con cantidad
/// - [ProductRemoved]: Remueve producto del carrito
/// - [PaymentMethodSelected]: Selecciona método de pago (cash/card)
/// - [SaleConfirmed]: Confirma y registra la venta en Local_DB
/// - [SaleCancellationRequested]: Solicita cancelar venta (verifica ventana)
/// - [CancellationPhotoTaken]: Completa cancelación con foto obligatoria
///
/// **Validates: Requirements 5.1, 5.4, 5.5, 5.6, 5.9, 6.1, 6.2**
class VentasBloc extends Bloc<VentasEvent, VentasState> {
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;
  final RegisterSaleUseCase _registerSaleUseCase;
  final CancelSaleUseCase _cancelSaleUseCase;
  final Uuid _uuid = const Uuid();

  // Estado interno del carrito (no parte del estado público)
  final List<SaleItem> _cartItems = [];
  PaymentMethod? _selectedPaymentMethod;

  VentasBloc({
    required GetProductsByCategoryUseCase getProductsByCategoryUseCase,
    required RegisterSaleUseCase registerSaleUseCase,
    required CancelSaleUseCase cancelSaleUseCase,
  }) : _getProductsByCategoryUseCase = getProductsByCategoryUseCase,
       _registerSaleUseCase = registerSaleUseCase,
       _cancelSaleUseCase = cancelSaleUseCase,
       super(const VentasInitial()) {
    on<CategorySelected>(_onCategorySelected);
    on<ProductAdded>(_onProductAdded);
    on<ProductRemoved>(_onProductRemoved);
    on<PaymentMethodSelected>(_onPaymentMethodSelected);
    on<SaleConfirmed>(_onSaleConfirmed);
    on<SaleCancellationRequested>(_onSaleCancellationRequested);
    on<CancellationPhotoTaken>(_onCancellationPhotoTaken);
  }

  /// Maneja [CategorySelected]
  ///
  /// 1. Emite [VentasLoading]
  /// 2. Llama a [GetProductsByCategoryUseCase] para cargar productos
  /// 3. Si exitoso: emite [ProductListView] con la lista de productos
  /// 4. Si falla: emite [SaleError] con el mensaje de error
  ///
  /// **Comportamiento Offline-First:**
  /// - Carga productos desde Local_DB (siempre disponible)
  /// - Si hay conectividad, sincroniza catálogo en background
  /// - Si el catálogo está vacío sin red, muestra lista vacía
  ///
  /// **Validates: Requirements 5.1, 5.2, 5.3, 11.1, 11.2**
  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<VentasState> emit,
  ) async {
    emit(const VentasLoading());

    final result = await _getProductsByCategoryUseCase(
      GetProductsByCategoryParams(
        businessId: event.businessId,
        category: event.category,
      ),
    );

    result.fold(
      (failure) => emit(SaleError(message: failure.message)),
      (products) =>
          emit(ProductListView(category: event.category, products: products)),
    );
  }

  /// Maneja [ProductAdded]
  ///
  /// 1. Valida que la cantidad esté en el rango válido (1–999,999,999)
  /// 2. Calcula el subtotal: cantidad × precio unitario
  /// 3. Agrega el producto al carrito interno como [SaleItem]
  /// 4. Emite [CartView] con la lista actualizada y el total calculado
  ///
  /// **Validates: Requirements 5.4, 5.5, 5.8**
  Future<void> _onProductAdded(
    ProductAdded event,
    Emitter<VentasState> emit,
  ) async {
    // Validar cantidad (debe estar en rango 1–999,999,999)
    if (event.quantity < 1 || event.quantity > 999999999) {
      emit(
        const SaleError(
          message: 'La cantidad debe estar entre 1 y 999,999,999',
        ),
      );
      return;
    }

    // Calcular subtotal
    final subtotal = event.quantity * event.product.price;

    // Crear SaleItem
    final saleItem = SaleItem(
      productId: event.product.id,
      productName: event.product.name,
      quantity: event.quantity,
      unitPrice: event.product.price,
      subtotal: subtotal,
    );

    // Agregar al carrito
    _cartItems.add(saleItem);

    // Calcular total del carrito
    final total = _cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    // Emitir estado del carrito
    emit(CartView(cartItems: List.unmodifiable(_cartItems), total: total));
  }

  /// Maneja [ProductRemoved]
  ///
  /// 1. Remueve el producto del carrito interno por productId
  /// 2. Recalcula el total del carrito
  /// 3. Si el carrito queda vacío: emite [VentasInitial]
  /// 4. Si aún hay productos: emite [CartView] actualizado
  ///
  /// **Validates: Requirement 5.5**
  Future<void> _onProductRemoved(
    ProductRemoved event,
    Emitter<VentasState> emit,
  ) async {
    // Remover el producto del carrito
    _cartItems.removeWhere((item) => item.productId == event.productId);

    // Si el carrito está vacío, regresar al estado inicial
    if (_cartItems.isEmpty) {
      emit(const VentasInitial());
      return;
    }

    // Recalcular total
    final total = _cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    // Emitir estado del carrito actualizado
    emit(CartView(cartItems: List.unmodifiable(_cartItems), total: total));
  }

  /// Maneja [PaymentMethodSelected]
  ///
  /// 1. Almacena el método de pago seleccionado (cash o card)
  /// 2. Emite [PaymentView] con el carrito y total actuales
  /// 3. El estado [PaymentView] muestra el resumen antes de confirmar
  ///
  /// **Validates: Requirement 5.6**
  Future<void> _onPaymentMethodSelected(
    PaymentMethodSelected event,
    Emitter<VentasState> emit,
  ) async {
    // Almacenar método de pago seleccionado
    _selectedPaymentMethod = event.paymentMethod;

    // Calcular total
    final total = _cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    // Emitir vista de pago con resumen
    emit(PaymentView(cartItems: List.unmodifiable(_cartItems), total: total));
  }

  /// Maneja [SaleConfirmed]
  ///
  /// 1. Verifica que haya productos en el carrito y método de pago seleccionado
  /// 2. Emite [VentasLoading]
  /// 3. Crea la entidad [Sale] con todos los datos
  /// 4. Llama a [RegisterSaleUseCase] para persistir en Local_DB
  /// 5. Si exitoso: emite [SaleSuccess], limpia el carrito interno
  /// 6. Si falla: emite [SaleError] sin limpiar el carrito (permite reintentar)
  ///
  /// **Comportamiento Offline-First:**
  /// - La venta se registra en Local_DB con is_synced = false
  /// - SyncService sincroniza con el backend en el siguiente ciclo de 5 min
  /// - La operación nunca falla por falta de conectividad
  ///
  /// **Validates: Requirements 5.6, 5.7, 5.9, 10.1, 10.2**
  Future<void> _onSaleConfirmed(
    SaleConfirmed event,
    Emitter<VentasState> emit,
  ) async {
    // Validar que haya productos en el carrito
    if (_cartItems.isEmpty) {
      emit(
        const SaleError(
          message:
              'El carrito está vacío. Agrega productos antes de confirmar.',
        ),
      );
      return;
    }

    // Validar que se haya seleccionado un método de pago
    if (_selectedPaymentMethod == null) {
      emit(
        const SaleError(
          message: 'Selecciona un método de pago antes de confirmar.',
        ),
      );
      return;
    }

    emit(const VentasLoading());

    // Calcular total
    final total = _cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    // Crear entidad Sale
    final sale = Sale(
      id: _uuid.v4(),
      sessionId: event.sessionId,
      businessId: event.businessId,
      cashierId: event.cashierId,
      items: List.unmodifiable(_cartItems),
      total: total,
      paymentMethod: _selectedPaymentMethod!,
      status: SaleStatus.completed,
      timestamp: DateTime.now(),
      isSynced: false, // Offline-first: se sincroniza después
    );

    // Registrar venta con use case
    final result = await _registerSaleUseCase(RegisterSaleParams(sale: sale));

    result.fold(
      (failure) {
        // Error: no limpiar el carrito para permitir reintentar
        emit(SaleError(message: failure.message));
      },
      (registeredSale) {
        // Éxito: limpiar carrito y método de pago
        _cartItems.clear();
        _selectedPaymentMethod = null;
        emit(SaleSuccess(sale: registeredSale));
      },
    );
  }

  /// Verifica si una venta es cancelable según la ventana anti-fraude
  ///
  /// Retorna `true` si han transcurrido menos de 5 minutos desde el timestamp
  /// de la venta. Esta función se debe verificar antes de mostrar la opción
  /// de cancelar y nuevamente al confirmar (guard contra race condition).
  ///
  /// **Validates: Requirements 6.1, 6.5**
  bool isCancellable(DateTime saleTimestamp) {
    final elapsed = DateTime.now().difference(saleTimestamp);
    return elapsed.inMinutes < 5;
  }

  /// Maneja [SaleCancellationRequested]
  ///
  /// 1. Verifica que la venta esté dentro de la ventana anti-fraude (< 5 min)
  /// 2. Si está dentro: emite [CancellationView] para activar la cámara
  /// 3. Si excede 5 minutos: emite [CancellationError] con mensaje de ventana expirada
  /// 4. Si cámara no disponible: la UI debe emitir [CancellationError] con [CameraFailure]
  ///
  /// **Validates: Requirements 6.1, 6.2, 6.3, 6.5**
  Future<void> _onSaleCancellationRequested(
    SaleCancellationRequested event,
    Emitter<VentasState> emit,
  ) async {
    // Validar ventana anti-fraude (< 5 minutos) - primera verificación
    if (!isCancellable(event.saleTimestamp)) {
      emit(
        const CancellationError(
          message: 'La venta no puede ser cancelada después de 5 minutos',
        ),
      );
      return;
    }

    // Emitir estado de cancelación para activar la cámara
    // La UI debe verificar isCancellable() nuevamente antes de confirmar
    // (guard contra race condition si pasan los 5 minutos mientras captura foto)
    emit(
      CancellationView(
        saleId: event.saleId,
        saleTimestamp: event.saleTimestamp,
      ),
    );
  }

  /// Maneja [CancellationPhotoTaken]
  ///
  /// 1. Verifica isCancellable() nuevamente (guard contra race condition)
  /// 2. Emite [VentasLoading]
  /// 3. Llama a [CancelSaleUseCase] con el ID de venta y la ruta de la foto
  /// 4. El use case valida la ventana anti-fraude nuevamente (race condition guard)
  /// 5. Si exitoso: emite [CancellationSuccess] con la venta cancelada
  /// 6. Si falla por CameraFailure o ValidationFailure: emite [CancellationError]
  /// 7. Si falla por otro motivo: emite [SaleError]
  ///
  /// **Comportamiento:**
  /// - La venta queda marcada como cancelled en Local_DB
  /// - Los totales del turno se revierten automáticamente
  /// - La foto queda asociada a la transacción para auditoría
  /// - La cancelación se sincroniza con el backend en el siguiente ciclo
  ///
  /// **Validates: Requirements 6.2, 6.3, 6.4, 6.5, 6.6, 6.7**
  Future<void> _onCancellationPhotoTaken(
    CancellationPhotoTaken event,
    Emitter<VentasState> emit,
  ) async {
    // Verificar isCancellable nuevamente antes de proceder (race condition guard)
    if (!isCancellable(event.saleTimestamp)) {
      emit(
        const CancellationError(
          message: 'La ventana de cancelación ha expirado (5 minutos)',
        ),
      );
      return;
    }

    emit(const VentasLoading());

    final result = await _cancelSaleUseCase(
      CancelSaleParams(
        saleId: event.saleId,
        photoPath: event.photoPath,
        saleTimestamp: event.saleTimestamp,
      ),
    );

    result.fold(
      (failure) {
        // Emitir CancellationError para errores específicos de cancelación
        if (failure is CameraFailure || failure is ValidationFailure) {
          emit(CancellationError(message: failure.message));
        } else {
          // Para otros errores (LocalDatabaseFailure, etc.), usar SaleError
          emit(SaleError(message: failure.message));
        }
      },
      (cancelledSale) =>
          emit(CancellationSuccess(cancelledSale: cancelledSale)),
    );
  }
}
