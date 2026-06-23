import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_event.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_state.dart';

/// Página de Equipo del Patron
///
/// Lista todos los Cajeros vinculados al negocio con el estado de turno
/// de cada uno (activo o inactivo). Permite al Patron ver quiénes están
/// trabajando en tiempo real.
///
/// Validado por Requirement 12.4: Listar Cajeros vinculados al negocio
/// con estado de turno (activo / inactivo)
class EquipoPage extends StatefulWidget {
  final String businessId;

  const EquipoPage({super.key, required this.businessId});

  @override
  State<EquipoPage> createState() => _EquipoPageState();
}

class _EquipoPageState extends State<EquipoPage> {
  @override
  void initState() {
    super.initState();
    // Load team on init
    _loadTeam();
  }

  void _loadTeam() {
    context.read<PatronBloc>().add(LoadTeamRequested(widget.businessId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeam,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: BlocBuilder<PatronBloc, PatronState>(
        builder: (context, state) {
          if (state is PatronLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PatronError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTeam,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is TeamLoaded) {
            return _buildTeamContent(state);
          }

          // Initial state
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add team member / show QR code
          _showAddMemberDialog();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Vincular Cajero'),
      ),
    );
  }

  Widget _buildTeamContent(TeamLoaded state) {
    if (state.team.isEmpty) {
      return _buildEmptyState();
    }

    // Separate active and inactive members
    final activeMembers = state.team.where((m) => m.hasActiveShift).toList();
    final inactiveMembers = state.team.where((m) => !m.hasActiveShift).toList();

    return RefreshIndicator(
      onRefresh: () async {
        _loadTeam();
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Summary card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.blue, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total de Cajeros',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.team.length}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${activeMembers.length} activos',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Active members section
          if (activeMembers.isNotEmpty) ...[
            Text(
              'Cajeros Activos (${activeMembers.length})',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...activeMembers.map((member) => _buildMemberCard(member, true)),
            const SizedBox(height: 24),
          ],

          // Inactive members section
          if (inactiveMembers.isNotEmpty) ...[
            Text(
              'Cajeros Inactivos (${inactiveMembers.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            ...inactiveMembers.map((member) => _buildMemberCard(member, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberCard(TeamMemberData member, bool isActive) {
    final statusColor = isActive ? Colors.green : Colors.grey;
    final statusText = isActive ? 'En turno' : 'Inactivo';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.shade100,
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : 'C',
            style: TextStyle(
              color: statusColor.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(member.email),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: statusColor.shade700),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay cajeros vinculados',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Usa el botón de abajo para vincular tu primer cajero mediante código QR',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vincular Cajero'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Para vincular un cajero, el cajero debe escanear el código QR del negocio desde su aplicación.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Ve a Configuración > Código QR para mostrar el código de vinculación.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to configuration QR page
              // context.push('/patron/configuracion?businessId=${widget.businessId}');
            },
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }
}
