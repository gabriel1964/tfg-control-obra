import 'package:flutter/material.dart';
import 'material_model.dart';
import 'material_service.dart';

class MaterialFormView extends StatefulWidget {
  final MaterialModel? material; // Null representa ALTA; si contiene datos representa EDICIÓN

  const MaterialFormView({super.key, this.material});

  @override
  State<MaterialFormView> createState() => _MaterialFormViewState();
}

class _MaterialFormViewState extends State<MaterialFormView> {
  final _formKey = GlobalKey<FormState>();
  final MaterialService _materialService = MaterialService();

  late TextEditingController _nombreController;
  late TextEditingController _cantidadController;
  late TextEditingController _unidadController;
  late TextEditingController _proveedorController;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores cargando datos existentes si es una edición
    _nombreController = TextEditingController(text: widget.material?.nombre ?? '');
    _cantidadController = TextEditingController(text: widget.material?.cantidad.toString() ?? '');
    _unidadController = TextEditingController(text: widget.material?.unidadMedida ?? '');
    _proveedorController = TextEditingController(text: widget.material?.proveedor ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _unidadController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }

  void _guardarFormulario() async {
    // Valida que las restricciones de los inputs se cumplan
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    // Mapea los campos de texto directamente a tu molde estructural
    final materialData = MaterialModel(
      id: widget.material?.id,
      nombre: _nombreController.text.trim(),
      cantidad: double.parse(_cantidadController.text.trim()),
      unidadMedida: _unidadController.text.trim(),
      proveedor: _proveedorController.text.trim().isEmpty ? null : _proveedorController.text.trim(),
    );

    try {
      if (widget.material == null) {
        // Operación de Escritura (CREATE)
        await _materialService.agregarMaterial(materialData);
      } else {
        // Operación de Modificación (UPDATE)
        await _materialService.actualizarMaterial(widget.material!.id!, materialData);
      }
      if (mounted) Navigator.pop(context); // Retorna a la lista tras guardar con éxito
    } catch (e) {
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.material != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Registro' : 'Nuevo Registro de Material'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600), // Mantiene el formulario estilizado en Windows
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Material *', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.text_fields)
                    ),
                    validator: (val) => val!.trim().isEmpty ? 'El nombre es obligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cantidadController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad Stock *', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.analytics)
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'La cantidad es obligatoria';
                      if (double.tryParse(val.trim()) == null) return 'Ingrese un valor numérico válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _unidadController,
                    decoration: const InputDecoration(
                      labelText: 'Unidad de Medida * (ej: Bolsas, Metros, Barras)', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten)
                    ),
                    validator: (val) => val!.trim().isEmpty ? 'La unidad de medida es obligatoria' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _proveedorController,
                    decoration: const InputDecoration(
                      labelText: 'Proveedor / Corralón (Opcional)', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business)
                    ),
                  ),
                  const SizedBox(height: 32),
                  _guardando
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _guardarFormulario,
                          icon: const Icon(Icons.save),
                          label: Text(
                            esEdicion ? 'Actualizar en Firestore' : 'Guardar en Firestore',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}