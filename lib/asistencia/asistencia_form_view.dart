import 'package:flutter/material.dart';
import 'asistencia_model.dart';
import 'package:flutter_tfg_1/asistencia/asistencia_service.dart'; // Import absoluto unificado
import '../views/widgets/custom_footer.dart'; // Import del Footer integrado

class AsistenciaFormView extends StatefulWidget {
  final String obraId; // ID de la obra actual seleccionada por el supervisor

  const AsistenciaFormView({super.key, required this.obraId});

  @override
  State<AsistenciaFormView> createState() => _AsistenciaFormViewState();
}

class _AsistenciaFormViewState extends State<AsistenciaFormView> {
  final AsistenciaService _asistenciaService = AsistenciaService();
  final _formKey = GlobalKey<FormState>();

  String? _operarioSeleccionado;
  bool _estaPresente = true;
  bool _guardando = false;

  // Guardamos el Future en una variable para evitar re-consultas innecesarias al redibujar
  late Future<List<String>> _futureOperarios;

  @override
  void initState() {
    super.initState();
    // Cargamos los operarios vinculados a esta obra desde Firestore (colección independiente)
    _futureOperarios = _asistenciaService.getOperariosPorObra(widget.obraId);
  }

  void _guardarAsistencia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    // Construcción del modelo orientado a objetos con los datos del formulario
    final nuevaAsistencia = AsistenciaModel(
      id: '', // Autogenerado por Firestore
      obraId: widget.obraId,
      operarioNombre: _operarioSeleccionado!,
      fecha: DateTime.now(),
      presente: _estaPresente,
    );

    try {
      // Llama a la lógica modificada de tu servicio
      await _asistenciaService.registrarAsistencia(nuevaAsistencia);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asistencia registrada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Regresa al listado de asistencias
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar asistencia: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Asistencia'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Expanded empuja el footer hacia la parte inferior de la pantalla de forma adaptativa
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Control de Personal - Supervisor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Carga dinámica de operarios buscando en la colección de Firestore
                    FutureBuilder<List<String>>(
                      future: _futureOperarios,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              'No se encontraron operarios asignados a esta obra.',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        final listaOperarios = snapshot.data!;

                        return DropdownButtonFormField<String>(
                          initialValue:
                              listaOperarios.contains(_operarioSeleccionado)
                                  ? _operarioSeleccionado
                                  : null,
                          decoration: const InputDecoration(
                            labelText: 'Seleccionar Operario',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: listaOperarios.map<DropdownMenuItem<String>>((
                            String operario,
                          ) {
                            return DropdownMenuItem<String>(
                              value: operario,
                              child: Text(operario),
                            );
                          }).toList(),
                          validator: (value) => value == null
                              ? 'Por favor, seleccione un operario'
                              : null,
                          onChanged: (String? nuevoValor) {
                            setState(() {
                              _operarioSeleccionado = nuevoValor;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Switch interactivo para alternar Presente / Ausente
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Estado de asistencia',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          _estaPresente ? 'Presente en Obra' : 'Ausente',
                          style: TextStyle(
                            color: _estaPresente ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        secondary: Icon(
                          _estaPresente ? Icons.check_circle : Icons.cancel,
                          color: _estaPresente ? Colors.green : Colors.red,
                          size: 30,
                        ),
                        value: _estaPresente,
                        onChanged: (bool value) {
                          setState(() {
                            _estaPresente = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Botón de acción principal controlado por el estado '_guardando'
                    ElevatedButton(
                      onPressed: _guardando ? null : _guardarAsistencia,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _guardando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Guardar Asistencia',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Footer fijo abajo de todo
          const CustomFooter(),
        ],
      ),
    );
  }
}