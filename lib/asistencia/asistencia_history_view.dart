import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha de manera linda
import 'asistencia_model.dart';
import 'asistencia_service.dart';

class AsistenciaHistoryView extends StatefulWidget {
  final String obraId;

  const AsistenciaHistoryView({super.key, required this.obraId});

  @override
  State<AsistenciaHistoryView> createState() => _AsistenciaHistoryViewState();
}

class _AsistenciaHistoryViewState extends State<AsistenciaHistoryView> {
  final AsistenciaService _asistenciaService = AsistenciaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Asistencias'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<List<AsistenciaModel>>(
        stream: _asistenciaService.getHistorialAsistencias(widget.obraId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el historial: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay registros de asistencia para esta obra.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final listaAsistencias = snapshot.data!;

          return ListView.builder(
            itemCount: listaAsistencias.length,
            padding: const EdgeInsets.all(12.0),
            itemBuilder: (context, index) {
              final asistencia = listaAsistencias[index];
              
              // Formateamos la fecha (Ej: 17/06/2026 15:30)
              final String fechaFormateada = 
                  DateFormat('dd/MM/yyyy HH:mm').format(asistencia.fecha);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: asistencia.presente 
                        ? Colors.green.withValues(alpha: 0.2) 
                        : Colors.red.withValues(alpha: 0.2),
                    child: Icon(
                      asistencia.presente ? Icons.check : Icons.close,
                      color: asistencia.presente ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    asistencia.operarioNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Fichado: $fechaFormateada',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: asistencia.presente ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      asistencia.presente ? 'Presente' : 'Ausente',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}