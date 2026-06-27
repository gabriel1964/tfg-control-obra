import 'package:flutter/material.dart';
import 'package:flutter_tfg_1/views/widgets/custom_footer.dart'; 
import 'material_service.dart';
// Asegúrate de importar tu vista de listado histórico si corresponde
// import 'material_list_view.dart'; 

class MaterialRequestView extends StatefulWidget {
  // NUEVO: Parámetros opcionales para recibir el documento a modificar desde el historial
  final String? pedidoId;
  final Map<String, dynamic>? pedidoAEditar;

  const MaterialRequestView({
    super.key, 
    this.pedidoId, 
    this.pedidoAEditar,
  });

  @override
  State<MaterialRequestView> createState() => _MaterialRequestViewState();
}

class _MaterialRequestViewState extends State<MaterialRequestView> {
  final _formKey = GlobalKey<FormState>();
  final MaterialService _materialService = MaterialService();
  
  late Future<List<String>> _futureMateriales;

  // Lista dinámica local para el pedido en pantalla (Tope de 10)
  List<Map<String, dynamic>> _pedidoItems = [
    {'material': null, 'cantidad': 1} // Iniciamos con null para que el Dropdown muestre 'Seleccionar'
  ];

  bool _esModificacion = false;

  @override
  void initState() {
    super.initState();
    // Petición directa y estricta a la base de datos central al inicializar la pantalla
    _futureMateriales = _materialService.obtenerCatalogoMateriales();

    // NUEVO: Si recibimos datos por el constructor, entramos en modo edición
    if (widget.pedidoId != null && widget.pedidoAEditar != null) {
      _esModificacion = true;
      _cargarPedidoParaModificar();
    }
  }

  // NUEVO: Procesa y mapea el listado guardado en la estructura dinámica local de la UI
  void _cargarPedidoParaModificar() {
    final itemsGuardados = widget.pedidoAEditar!['items'] as List<dynamic>?;
    if (itemsGuardados != null && itemsGuardados.isNotEmpty) {
      _pedidoItems = itemsGuardados.map((item) {
        return {
          'material': item['material']?.toString(),
          'cantidad': int.tryParse(item['cantidad'].toString()) ?? 1
        };
      }).toList();
    }
  }

  void _agregarItem() {
    if (_pedidoItems.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Control de Gestión: Máximo 10 elementos por solicitud.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _pedidoItems.add({'material': null, 'cantidad': 1});
    });
  }

  void _eliminarItem(int index) {
    if (_pedidoItems.length > 1) {
      setState(() {
        _pedidoItems.removeAt(index);
      });
    }
  }

  void _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      if (_esModificacion) {
        // Lógica de Modificación: Actualiza el registro existente en Firestore
        await _materialService.actualizarPedido(widget.pedidoId!, _pedidoItems);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud de materiales modificada con éxito en el sistema central.'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // Lógica de Creación: Guarda un pedido nuevo
        await _materialService.guardarNuevoPedido(_pedidoItems);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido de materiales registrado con éxito en el sistema central.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar la solicitud: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      appBar: AppBar(
        // NUEVO: Título dinámico adaptado a la operación
        title: Text(
          _esModificacion ? 'Modificar Pedido' : 'Pedido de Materiales', 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        backgroundColor: const Color(0xFFFDFBFF),
        elevation: 0,
        // NUEVO: Botón de acceso directo en las acciones de la barra superior para ir al historial
        actions: [
          IconButton(
            icon: const Icon(Icons.history_toggle_off_rounded, color: Color(0xFF0F5EA3), size: 26),
            tooltip: 'Ver historial de listas',
            onPressed: () {
              // Redirección directa al listado para auditar y seleccionar
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const MaterialListView()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abriendo Historial de Listas Guardadas...')),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _futureMateriales,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF0F5EA3)),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
                            const SizedBox(height: 16),
                            const Text(
                              "Error de Sincronización",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "No se pudo conectar al servidor. Reintente más tarde.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _futureMateriales = _materialService.obtenerCatalogoMateriales();
                                });
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5EA3)),
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                              label: const Text("Reintentar Conexión", style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  final catalogoDb = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _esModificacion ? "Editar Solicitud Insumos" : "Nueva Solicitud de Insumos",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.cloud_done_rounded, size: 16, color: _esModificacion ? Colors.blue : Colors.green),
                              const SizedBox(width: 6),
                              Text(
                                _esModificacion 
                                  ? "Modificando un registro histórico sincronizado."
                                  : "Catálogo validado en tiempo real con el servidor central.",
                                style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _pedidoItems.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButtonFormField<String>(
                                          initialValue: catalogoDb.contains(_pedidoItems[index]['material']) 
                                              ? _pedidoItems[index]['material'] 
                                              : null,
                                          decoration: const InputDecoration(
                                            labelText: 'Material',
                                            border: InputBorder.none,
                                          ),
                                          hint: const Text('Seleccionar'),
                                          items: catalogoDb.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                            );
                                          }).toList(),
                                          validator: (value) => value == null ? 'Requerido' : null,
                                          onChanged: (value) {
                                            setState(() {
                                              _pedidoItems[index]['material'] = value;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          // Se controla el valor inicial dinámicamente si es una edición
                                          key: Key('cant_${index}_${_pedidoItems[index]['cantidad']}'),
                                          initialValue: _pedidoItems[index]['cantidad'].toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Cant.',
                                            border: InputBorder.none,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) return 'Error';
                                            final n = int.tryParse(value);
                                            if (n == null || n <= 0) return 'Inválido';
                                            return null;
                                          },
                                          onChanged: (value) {
                                            _pedidoItems[index]['cantidad'] = int.tryParse(value) ?? 1;
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        onPressed: () => _eliminarItem(index),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _agregarItem,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F5EA3),
                              side: const BorderSide(color: Color(0xFF0F5EA3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text("Añadir Material"),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                // Cambia el color del botón principal si es una actualización transaccional
                                backgroundColor: _esModificacion ? const Color(0xFF0F5EA3) : const Color(0xFFFF6D00),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _enviarSolicitud,
                              child: Text(
                                _esModificacion ? "CONFIRMAR MODIFICACIÓN" : "SOLICITAR INSUMOS", 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }
}