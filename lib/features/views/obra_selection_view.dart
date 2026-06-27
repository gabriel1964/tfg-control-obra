import 'package:flutter/material.dart';
import 'package:flutter_tfg_1/features/services/obra_service.dart';
import 'package:flutter_tfg_1/material/obra_model.dart'; // Importación correcta del modelo específico de obras
import 'supervisor_panel_view.dart'; // Importación directa por compartir la carpeta views

// Importación de componentes globales de interfaz
import 'package:flutter_tfg_1/views/widgets/custom_footer.dart';

class ObraSelectionView extends StatefulWidget {
  const ObraSelectionView({super.key});

  @override
  State<ObraSelectionView> createState() => _ObraSelectionViewState();
}

class _ObraSelectionViewState extends State<ObraSelectionView> {
  final ObraService _obraService = ObraService();
  
  // Sincronizado para usar ObraModel tal como retorna el ObraService
  late Future<List<ObraModel>> _futureObras; 

  @override
  void initState() {
    super.initState();
    // Lanzamos la petición a Firebase al iniciar la pantalla
    _futureObras = _obraService.obtenerObras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Frente de Obra'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ObraModel>>(
              future: _futureObras,
              builder: (context, snapshot) {
                // 1. Estado de carga
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // 2. Control de errores
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al conectar con la base de datos:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // 3. Si no hay datos devueltos
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay frentes de obra activos registrados.'),
                  );
                }

                final listaObras = snapshot.data!;

                // 4. Renderizado del listado dinámico
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: listaObras.length,
                  itemBuilder: (context, index) {
                    final obra = listaObras[index];
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.foundation, color: Colors.white),
                        ),
                        title: Text(
                          obra.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: const Text('DES S.R.L. • Infraestructura'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          // Al seleccionar, se avanza al Panel Supervisor enviando el objeto estructurado de la obra
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupervisorPanelView(obraSeleccionada: obra),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Pie de página institucional reutilizable
          const CustomFooter(),
        ],
      ),
    );
  }
}