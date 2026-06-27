import 'package:flutter/material.dart';
import 'asistencia_model.dart';
import 'asistencia_service.dart';
import 'asistencia_form_view.dart';
import 'asistencia_history_view.dart';
import '../views/widgets/custom_footer.dart'; // <-- Import del Footer 

class AsistenciaListView extends StatefulWidget {
  final String obraId;

  const AsistenciaListView({super.key, required this.obraId});

  @override
  State<AsistenciaListView> createState() => _AsistenciaListViewState();
}

class _AsistenciaListViewState extends State<AsistenciaListView> {
  final AsistenciaService _asistenciaService = AsistenciaService();

  bool _esHoy(DateTime fecha) {
    final hoy = DateTime.now();
    return fecha.year == hoy.year && fecha.month == hoy.month && fecha.day == hoy.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia del Día'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver Historial',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AsistenciaHistoryView(obraId: widget.obraId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Expanded obliga a la lista a ocupar todo el espacio superior disponible
          Expanded(
            child: StreamBuilder<List<AsistenciaModel>>(
              stream: _asistenciaService.getHistorialAsistencias(widget.obraId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final registrosHoy = snapshot.data?.where((a) => _esHoy(a.fecha)).toList() ?? [];

                if (registrosHoy.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Aún no se han registrado asistencias el día de hoy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: registrosHoy.length,
                  padding: const EdgeInsets.all(12.0),
                  itemBuilder: (context, index) {
                    final asistencia = registrosHoy[index];

                    return Card(
                      elevation: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: asistencia.presente 
                              ? Colors.green.withAlpha(51) 
                              : Colors.red.withAlpha(51),
                          child: Icon(
                            asistencia.presente ? Icons.sentiment_satisfied : Icons.sentiment_dissatisfied,
                            color: asistencia.presente ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          asistencia.operarioNombre,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Text(
                          asistencia.presente ? 'Presente' : 'Ausente',
                          style: TextStyle(
                            color: asistencia.presente ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // El footer se queda fijo abajo de todo de forma limpia
          const CustomFooter(), 
        ],
      ),
      floatingActionButton: Padding(
        // Un pequeño margen inferior para que el FAB no tape el contenido del footer
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AsistenciaFormView(obraId: widget.obraId),
              ),
            );
          },
          backgroundColor: Colors.blueAccent,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Tomar Asistencia', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}