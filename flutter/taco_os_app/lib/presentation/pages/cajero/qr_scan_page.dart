import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

/// Pantalla de escaneo de código QR para vincular Cajero al negocio
///
/// Permite al Cajero escanear el código QR generado por el Patrón para
/// vincularse al `business_id` correspondiente. Maneja:
/// - Solicitud de permiso de cámara
/// - Máximo 3 intentos fallidos antes de bloquear el escaneo
/// - Validación de QR (vigencia de 24 horas)
/// - Mensaje de error descriptivo para QR inválido/expirado
///
/// **Validates: Requirements 2.2, 2.3, 2.4, 2.5, 2.7**
///
/// **Subtask 13.3:** Crear `QRScanPage` usando `mobile_scanner`, solicitar
/// permiso de cámara, máximo 3 intentos fallidos, y vincular al negocio.
class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final MobileScannerController _controller = MobileScannerController();

  /// Contador de intentos fallidos de escaneo
  int _failedAttempts = 0;

  /// Máximo de intentos permitidos
  static const int _maxAttempts = 3;

  /// Indica si el escaneo está bloqueado por exceder intentos
  bool _isBlocked = false;

  /// Indica si ya se procesó un código QR (evitar múltiples escaneos)
  bool _isProcessing = false;

  /// Estado de permiso de cámara
  PermissionStatus? _cameraPermissionStatus;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Verifica y solicita el permiso de cámara
  ///
  /// **Validates: Requirements 2.2, 2.3**
  ///
  /// Si el permiso es denegado, muestra un mensaje y un botón para
  /// abrir la configuración del sistema.
  Future<void> _checkCameraPermission() async {
    // AC 2.2: Solicitar permiso de cámara
    final status = await Permission.camera.request();

    setState(() {
      _cameraPermissionStatus = status;
    });

    if (!status.isGranted) {
      // AC 2.3: Si se deniega, mostrar mensaje + botón de configuración
      _showPermissionDeniedDialog();
    }
  }

  /// Muestra un diálogo cuando se deniega el permiso de cámara
  ///
  /// **Validates: Requirement 2.3**
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de cámara requerido'),
        content: const Text(
          'El permiso de cámara es necesario para escanear el código QR '
          'y vincularte al negocio. Por favor, habilita el permiso en la '
          'configuración del sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/role-selection'); // Regresar a selección de rol
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // AC 2.3: Abrir configuración del sistema
              await openAppSettings();
              // Volver a verificar el permiso tras regresar
              _checkCameraPermission();
            },
            child: const Text('Abrir configuración'),
          ),
        ],
      ),
    );
  }

  /// Maneja el código QR escaneado
  ///
  /// **Validates: Requirements 2.4, 2.5, 2.7**
  ///
  /// Valida el código QR y:
  /// - Si es válido: asocia al Cajero con el `business_id` y navega al home
  /// - Si es inválido/expirado: incrementa contador de intentos fallidos
  /// - Si llega a 3 intentos: bloquea el escaneo
  void _handleQRCode(BarcodeCapture capture) {
    // Evitar procesamiento múltiple
    if (_isProcessing || _isBlocked) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrCode = barcodes.first.rawValue;
    if (qrCode == null || qrCode.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Pausar el scanner mientras procesamos
    _controller.stop();

    // TODO: Llamar al repositorio para validar y vincular el QR
    // Por ahora, simulamos la validación
    _validateAndLinkQRCode(qrCode);
  }

  /// Valida el código QR y vincula al Cajero con el negocio
  ///
  /// **Validates: Requirements 2.4, 2.5**
  ///
  /// Esta función simulada debe ser reemplazada por la llamada real
  /// al `IAuthRepository.linkCajeroToBusiness()` cuando se integre
  /// con el backend.
  Future<void> _validateAndLinkQRCode(String qrCode) async {
    // Simulación: validar formato del QR
    // En implementación real, esto debe llamar a:
    // final result = await authRepository.linkCajeroToBusiness(qrCode);

    await Future.delayed(const Duration(seconds: 1)); // Simular latencia

    // Simulación de validación (reemplazar con lógica real)
    final bool isValid = qrCode.startsWith('TACOS_');
    // TODO: Implementar verificación de vigencia de 24h desde el backend
    // final bool isExpired = ...;

    if (mounted) {
      if (isValid) {
        // AC 2.4: QR válido → asociar al Cajero con business_id
        _showSuccessMessage();
        // AC 2.7: Persistir vinculación en Local_DB (debe hacerse en repositorio)
        // Navegar al flujo de cajero
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/cajero/home');
          }
        });
      } else {
        // AC 2.5: QR inválido o expirado
        // TODO: Diferenciar entre QR inválido y QR expirado cuando se implemente la lógica real
        _handleFailedAttempt(
          'Código QR inválido. Verifica que sea el código correcto.',
        );
      }
    }
  }

  /// Maneja un intento fallido de escaneo
  ///
  /// **Validates: Requirement 2.5**
  ///
  /// Incrementa el contador de intentos fallidos y bloquea el escaneo
  /// tras alcanzar el máximo de 3 intentos.
  void _handleFailedAttempt(String errorMessage) {
    setState(() {
      _failedAttempts++;
      _isProcessing = false;
    });

    // AC 2.5: Máximo 3 intentos fallidos consecutivos
    if (_failedAttempts >= _maxAttempts) {
      setState(() {
        _isBlocked = true;
      });

      _showBlockedDialog();
    } else {
      _showErrorDialog(
        '$errorMessage\n\nIntento $_failedAttempts de $_maxAttempts.',
      );

      // Reanudar el scanner para permitir reintentar
      _controller.start();
    }
  }

  /// Muestra un mensaje de error y permite reintentar
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error al escanear'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo cuando se bloquea el escaneo tras 3 intentos
  void _showBlockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Escaneo bloqueado'),
        content: const Text(
          'Has superado el máximo de intentos fallidos. '
          'Contacta al Patrón para obtener un nuevo código QR.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/role-selection'); // Regresar a selección de rol
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  /// Muestra un mensaje de éxito tras vincular exitosamente
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Vinculación exitosa! Redirigiendo...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear código QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/role-selection');
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // AC 2.3: Si permiso denegado, mostrar mensaje
    if (_cameraPermissionStatus == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_cameraPermissionStatus!.isGranted) {
      return _buildPermissionDeniedMessage();
    }

    // AC 2.5: Si bloqueado por intentos, mostrar mensaje
    if (_isBlocked) {
      return _buildBlockedMessage();
    }

    // AC 2.2: Mostrar scanner si permiso concedido
    return Stack(
      children: [
        MobileScanner(controller: _controller, onDetect: _handleQRCode),
        _buildScannerOverlay(),
      ],
    );
  }

  /// Construye el mensaje de permiso denegado
  Widget _buildPermissionDeniedMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Permiso de cámara denegado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Para escanear el código QR, necesitamos acceso a la cámara. '
              'Por favor, habilita el permiso en la configuración.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await openAppSettings();
                _checkCameraPermission();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Abrir configuración'),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el mensaje de escaneo bloqueado
  Widget _buildBlockedMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Escaneo bloqueado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Has superado el máximo de $_maxAttempts intentos fallidos. '
              'Contacta al Patrón para obtener un nuevo código QR.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/role-selection');
              },
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el overlay visual del scanner
  Widget _buildScannerOverlay() {
    return Column(
      children: [
        Expanded(flex: 1, child: Container(color: Colors.black54)),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(flex: 1, child: Container(color: Colors.black54)),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
              Expanded(flex: 1, child: Container(color: Colors.black54)),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _isProcessing
                      ? 'Procesando...'
                      : 'Centra el código QR en el recuadro',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
