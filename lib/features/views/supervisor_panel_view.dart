import 'package:flutter/material.dart';
import 'package:flutter_tfg_1/material/obra_model.dart'; // Importación correcta del modelo de obras
import 'package:flutter_tfg_1/material/material_list_view.dart'; // Tu pantalla de Control/Listado de Materiales globales
import 'package:flutter_tfg_1/material/material_request_view.dart';
import 'package:flutter_tfg_1/views/widgets/custom_footer.dart'; // Tu pie de página institucional
import 'package:flutter_tfg_1/asistencia/asistencia_list_view.dart';

class SupervisorPanelView extends StatelessWidget {
  final ObraModel
  obraSeleccionada; // Modelo para mantener la coherencia del flujo de la obra logueada

  const SupervisorPanelView({super.key, required this.obraSeleccionada});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Panel Supervisor'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicador del frente de obra actual en el que se encuentra logueado el supervisor
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: Colors.blueAccent.withValues(alpha: 0.1),
              width: double.infinity,
              child: Text(
                'Obra: ${obraSeleccionada.nombre}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Grilla modular con las tarjetas de acceso con redirección correcta
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Wrap(
                    spacing: 16, // Espacio horizontal entre tarjetas
                    runSpacing: 16, // Espacio vertical si saltan de línea
                    alignment: WrapAlignment.center,
                    children: [
                      // 1. MÓDULO ASISTENCIA (MANUAL)
                      SizedBox(
                        width: 160,
                        child: _MenuCard(
                          title: 'Asistencia',
                          icon: Icons.how_to_reg,
                          iconColor: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Extraemos el id en formato String desde el objeto ObraModel
                                builder: (context) => AsistenciaListView(
                                  obraId: obraSeleccionada.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // 2. MÓDULO PEDIDOS (MATERIALES DE LA OBRA)
                      SizedBox(
                        width: 160,
                        child: _MenuCard(
                          title: 'Pedidos',
                          icon: Icons.shopping_cart,
                          iconColor: Colors.orange,
                          onTap: () {
                            // CORRECCIÓN: Modificar el destino a la pantalla que gestiona el formulario/lista de pedidos específicos de la obra
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //const SnackBar(content: Text('Navegando a Solicitudes y Pedidos de Obra')),
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MaterialRequestView(), // Tu vista de transacciones/pedidos
                              ),
                            );
                          },
                        ),
                      ),

                      // 3. MÓDULO AGREGADO DE MATERIAL NUEVO (CONTROL DE STOCK / BASE DE DATOS)
                      SizedBox(
                        width: 160,
                        child: _MenuCard(
                          title: 'Nuevo Material',
                          icon: Icons
                              .inventory, // Cambiado a un ícono que representa el maestro de artículos/materiales
                          iconColor: Colors.teal,
                          onTap: () {
                            // DIRECCIONAMIENTO: Navega directo a la pantalla de la captura "Control de Materiales"
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MaterialListView(), // Esta clase maneja la lista global de la base de datos
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pie de página institucional
            const CustomFooter(),
          ],
        ),
      ),
    );
  }
}

// Componente secundario reutilizable para las tarjetas del menú del supervisor
class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6FA),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
