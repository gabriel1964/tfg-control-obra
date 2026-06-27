import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'material_service.dart';
import 'material_request_view.dart';

class MaterialHistoryView extends StatelessWidget {
  const MaterialHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialService materialService = MaterialService();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      appBar: AppBar(
        title: const Text('Historial de Solicitudes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFDFBFF),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: materialService.obtenerHistorialPedidos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0F5EA3)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No se encontraron listas o pedidos registrados.', style: TextStyle(color: Colors.black54)),
            );
          }

          final pedidos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final doc = pedidos[index];
              final data = doc.data() as Map<String, dynamic>;
              final List<dynamic> items = data['items'] ?? [];
              
              // Formateo básico de fecha para la UI del frente de obra
              final Timestamp? t = data['fecha'] as Timestamp?;
              final String fechaStr = t != null 
                  ? "${t.toDate().day}/${t.toDate().month}/${t.toDate().year} - ${t.toDate().hour}:${t.toDate().minute.toString().padLeft(2, '0')}"
                  : "Reciente";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: const Icon(Icons.assignment_outlined, color: Color(0xFF0F5EA3)),
                  title: Text('Pedido del $fechaStr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('${items.length} materiales solicitados • Estado: ${data['estado'] ?? 'Pendiente'}', style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.edit_note_rounded, color: Colors.amber, size: 28), // Icono estético de modificación
                  onTap: () {
                    // Al seleccionar, viaja al formulario cargando los datos correspondientes en modo Edición
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaterialRequestView(
                          pedidoId: doc.id,
                          pedidoAEditar: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}