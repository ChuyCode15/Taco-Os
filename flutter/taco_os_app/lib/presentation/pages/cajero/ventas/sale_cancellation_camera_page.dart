import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_state.dart';

/// Página de captura de foto para cancelación de venta
///
/// Activa la cámara para capturar la foto obligatoria del producto devuelto.
/// Solo se accede a esta página si la venta está dentro de la ventana
/// anti-fraude (< 5 minutos).
///
/// **Features:**
/// - Activación de cámara usando image_picker
/// - Foto obligatoria para completar la cancelación
/// - Verificación final de isCancellable() antes de confirmar (race condition guard)
/// - Manejo de error si cámara no disponible
/// - Previene cancelación si no se captura foto
///
/// **Validates: Requirements 6.2, 6.3, 6.4, 6.6**
class SaleCancellationCameraPage extends StatefulWidget {
  const SaleCancellationCameraPage({super.key});

  @override
  State<SaleCancellationCameraPage> createState() =>
      _SaleCancellationCameraPageState();
}

class _SaleCancellationCameraPageState
    extends State<SaleCancellationCameraPage> {
  final ImagePicker _picker = ImagePicker();
  String? _capturedPhotoPath;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    // Activar cámara automáticamente al entrar a la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capturePhoto();
    });
  }

  /// Activa la cámara para capturar la foto obligatoria
  ///
  /// Si el usuario cancela o la cámara no está disponible,
  /// muestra un error y permite reintentar.
  ///
  /// **Validates: Requirements 6.2, 6.3**
  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _capturedPhotoPath = photo.path;
          _isCapturing = false;
        });
      } else {
        // Usuario canceló la captura
        setState(() {
          _isCapturing = false;
        });
        if (mounted) {
          _showCameraError('Captura cancelada. La foto es obligatoria.');
        }
      }
    } catch (e) {
      // Error al acceder a la cámara
      setState(() {
        _isCapturing = false;
      });
      if (mounted) {
        _showCameraError(
          'No se pudo acceder a la cámara. Verifica los permisos.',
        );
      }
    }
  }

  /// Muestra un mensaje de error relacionado con la cámara
  void _showCameraError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: _capturePhoto,
        ),
      ),
    );
  }

  /// Confirma la cancelación con la foto capturada
  ///
  /// Verifica que se haya capturado una foto y dispara el evento
  /// CancellationPhotoTaken en VentasBloc.
  ///
  /// El BLoC verificará isCancellable() nuevamente antes de proceder
  /// (guard contra race condition).
  ///
  /// **Validates: Requirements 6.2, 6.4, 6.6**
  void _confirmCancellation() {
    if (_capturedPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes capturar una foto del producto devuelto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final state = context.read<VentasBloc>().state;
    if (state is! CancellationView) {
      context.pop();
      return;
    }

    // Disparar evento con la foto capturada
    context.read<VentasBloc>().add(
      CancellationPhotoTaken(
        saleId: state.saleId,
        photoPath: _capturedPhotoPath!,
        saleTimestamp: state.saleTimestamp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VentasBloc, VentasState>(
      listener: (context, state) {
        // Si la cancelación fue exitosa, navegar de regreso
        if (state is CancellationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Venta cancelada exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          context.go('/cajero/home');
        }

        // Si hubo un error, mostrar mensaje
        if (state is SaleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cancelar Venta'),
          centerTitle: true,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<VentasBloc, VentasState>(
          builder: (context, state) {
            // Mostrar loading mientras procesa la cancelación
            if (state is VentasLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Procesando cancelación...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return _buildCameraContent();
          },
        ),
      ),
    );
  }

  /// Construye el contenido de la página de cámara
  Widget _buildCameraContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Advertencia de ventana anti-fraude
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.red, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foto Obligatoria',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Debes capturar una foto del producto devuelto como evidencia de la cancelación.',
                        style: TextStyle(fontSize: 14, color: Colors.red[900]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Vista previa de la foto capturada o botón para capturar
          if (_capturedPhotoPath != null) ...[
            // Vista previa de la foto
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(File(_capturedPhotoPath!), fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),

            // Botón para recapturar
            OutlinedButton.icon(
              onPressed: _isCapturing ? null : _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Volver a Capturar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ] else ...[
            // Botón para capturar foto inicial
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isCapturing
                          ? 'Abriendo cámara...'
                          : 'Toca para capturar foto',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _capturePhoto,
              icon: const Icon(Icons.camera_alt, size: 28),
              label: const Text(
                'Capturar Foto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Botón de confirmar cancelación (solo si hay foto)
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _capturedPhotoPath != null
                  ? _confirmCancellation
                  : null,
              icon: const Icon(Icons.cancel, size: 24),
              label: const Text(
                'Confirmar Cancelación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _capturedPhotoPath != null
                    ? Colors.red
                    : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón de cancelar el proceso
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Regresar sin cancelar',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
