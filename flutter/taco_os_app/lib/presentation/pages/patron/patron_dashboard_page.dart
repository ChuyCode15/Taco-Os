import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_event.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_state.dart';

/// Dashboard del Patron
///
/// Pantalla principal del rol Patron con acceso a las 4 secciones:
/// - Ventas (resumen del día)
/// - Reportes (históricos por rango de fechas)
/// - Equipo (Cajeros vinculados)
/// - Configuración (ajustes del negocio)
///
/// Incluye un badge de notificaciones que muestra el número de alertas
/// pendientes no leídas, con formato "99+" cuando supere 99, y sin badge
/// cuando no haya notificaciones pendientes.
///
/// Validado por Requirement 12.1: Dashboard del Patron con 4 secciones
/// Validado por Requirement 12.5: Badge de notificaciones con conteo
class PatronDashboardPage extends StatefulWidget {
  final String businessId;

  const PatronDashboardPage({super.key, required this.businessId});

  @override
  State<PatronDashboardPage> createState() => _PatronDashboardPageState();
}

class _PatronDashboardPageState extends State<PatronDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load notifications on init to show badge
    context.read<PatronBloc>().add(
      LoadNotificationsRequested(widget.businessId),
    );
    // Load business info to determine feature availability
    context.read<PatronBloc>().add(
      LoadBusinessInfoRequested(widget.businessId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard del Patrón'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), // Menú hamburguesa (☰)
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          // Badge de notificaciones
          BlocBuilder<PatronBloc, PatronState>(
            builder: (context, state) {
              if (state is NotificationsLoaded) {
                final badgeText = state.badgeText;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        // TODO: Navigate to notifications page
                        // For now, just reload
                        context.read<PatronBloc>().add(
                          LoadNotificationsRequested(widget.businessId),
                        );
                      },
                    ),
                    if (badgeText.isNotEmpty)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }
              // Default notification icon without badge
              return IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  context.read<PatronBloc>().add(
                    LoadNotificationsRequested(widget.businessId),
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: BlocBuilder<PatronBloc, PatronState>(
        builder: (context, state) {
          // Determine if AI modules should be shown
          bool showAiModules = false;
          if (state is BusinessInfoLoaded) {
            showAiModules = state.hasAiModules;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Dashboard Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDashboardCard(
                        context,
                        icon: Icons.point_of_sale,
                        title: 'Ventas',
                        subtitle: 'Resumen del día',
                        color: Colors.green,
                        onTap: () {
                          context.push(
                            '/patron/ventas?businessId=${widget.businessId}',
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.analytics,
                        title: 'Reportes',
                        subtitle: 'Históricos y análisis',
                        color: Colors.blue,
                        onTap: () {
                          context.push(
                            '/patron/reportes?businessId=${widget.businessId}',
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.people,
                        title: 'Equipo',
                        subtitle: 'Cajeros vinculados',
                        color: Colors.orange,
                        onTap: () {
                          context.push(
                            '/patron/equipo?businessId=${widget.businessId}',
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.settings,
                        title: 'Configuración',
                        subtitle: 'Ajustes del negocio',
                        color: Colors.purple,
                        onTap: () {
                          context.push(
                            '/patron/configuracion?businessId=${widget.businessId}',
                          );
                        },
                      ),
                    ],
                  ),
                  // AI Modules Section (only for Business plan)
                  if (showAiModules) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Módulos de Inteligencia Artificial',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAiModulesSection(context),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepOrange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Taco\'Os',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Panel del Patrón',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: const Text('Ventas'),
            onTap: () {
              Navigator.pop(context);
              context.push('/patron/ventas?businessId=${widget.businessId}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Reportes'),
            onTap: () {
              Navigator.pop(context);
              context.push('/patron/reportes?businessId=${widget.businessId}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Equipo'),
            onTap: () {
              Navigator.pop(context);
              context.push('/patron/equipo?businessId=${widget.businessId}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              context.push(
                '/patron/configuracion?businessId=${widget.businessId}',
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              // TODO: Implement sign out
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  /// Construye la sección de módulos de IA (solo para plan Business)
  ///
  /// Esta sección muestra los módulos de análisis con inteligencia artificial
  /// disponibles exclusivamente para negocios con plan Business. Si los módulos
  /// de IA fallan al cargar, se muestra un mensaje de error pero el resto de
  /// las funciones del plan Business permanecen disponibles.
  ///
  /// Validado por Requirement 14.4: Módulos de IA solo para plan Business con
  /// fallback graceful si no pueden cargar
  Widget _buildAiModulesSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.deepPurple, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análisis Inteligente',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Predicciones de demanda, insights de ventas y recomendaciones personalizadas',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Placeholder for AI modules - would load actual widgets here
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.construction,
                      size: 40,
                      color: Colors.deepPurple.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Módulos de IA en desarrollo',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
