import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'material_model.dart';

class MaterialService {
  // Referencia a la colección del catálogo base de materiales
  final CollectionReference _materialesCollection = 
      FirebaseFirestore.instance.collection('materiales');

  // Referencia a la colección transaccional de pedidos de la constructora
  final CollectionReference _solicitudesCollection = 
      FirebaseFirestore.instance.collection('solicitudes_materiales');

  // =========================================================================
  // CATALOGO: Lectura para los desplegables (Dropdowns)
  // =========================================================================
  /// Obtiene una lista con los nombres de los materiales de forma asíncrona (Petición única).
  Future<List<String>> obtenerCatalogoMateriales() async {
    try {
      QuerySnapshot snapshot = await _materialesCollection.get();
      
      List<String> nombresMateriales = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['nombre'] as String? ?? 'Material sin nombre';
      }).toList();

      nombresMateriales.sort();
      return nombresMateriales;
    } catch (e) {
      debugPrint("Error crítico en obtenerCatalogoMateriales: $e");
      rethrow;
    }
  }

  // =========================================================================
  // ESCRITURA: Persistencia de Solicitudes (Altas y Modificaciones)
  // =========================================================================
  
  /// Registra una nueva solicitud de materiales en el sistema central.
  /// Mapea los datos dinámicos asegurando el tipado estricto que requiere Firestore.
  Future<void> guardarNuevoPedido(List<Map<String, dynamic>> items) async {
    try {
      final itemsValidos = _procesarYValidarItems(items);

      final Map<String, dynamic> nuevaSolicitud = {
        'supervisor': 'Supervisor de Obra', // Vinculable con tu sistema de Auth / Sesión
        'fecha_creacion': FieldValue.serverTimestamp(),
        'items': itemsValidos,
        'estado': 'Pendiente', // Estado inicial para control de auditoría de la constructora
      };

      await _solicitudesCollection.add(nuevaSolicitud);
    } catch (e) {
      debugPrint("Error crítico en guardarNuevoPedido: $e");
      rethrow;
    }
  }

  /// Actualiza de forma física una hoja de ruta o solicitud existente seleccionada.
  Future<void> actualizarPedido(String pedidoId, List<Map<String, dynamic>> items) async {
    try {
      final itemsValidos = _procesarYValidarItems(items);

      await _solicitudesCollection.doc(pedidoId).update({
        'items': itemsValidos,
        'ultima_modificacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error crítico en actualizarPedido para el ID $pedidoId: $e");
      rethrow;
    }
  }

  // =========================================================================
  // HISTORIAL: Flujos reactivos de las solicitudes de obra
  // =========================================================================
  
  // MODIFICACIÓN DE SEGURIDAD: Tolerancia a metadatos pendientes de servidor
  /// Devuelve un flujo continuo de datos de las solicitudes ordenadas cronológicamente.
  Stream<QuerySnapshot> obtenerHistorialPedidos() {
    return _solicitudesCollection
        .orderBy('fecha_creacion', descending: true)
        .snapshots(includeMetadataChanges: true); // Evita caídas del flujo durante la latencia de red
  }

  // =========================================================================
  // NUEVO MÉTODO: Inicialización de Base de Datos (Semilla / Seed)
  // =========================================================================
  /// Fuerza a que la colección aparezca en la consola de Firebase con un "documento molde"
  /// de prueba si se encuentra completamente vacía, evitando fallos de lectura en la UI.
  Future<void> inicializarBaseSolicitudes() async {
    try {
      // Verificamos si ya existen documentos para no duplicar la semilla en producción
      QuerySnapshot snapshot = await _solicitudesCollection.limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        debugPrint("Inicializando la base de solicitudes_materiales con un documento semilla...");
        
        await _solicitudesCollection.add({
          'supervisor': 'Sistema de Inicialización',
          'fecha_creacion': FieldValue.serverTimestamp(),
          'estado': 'Inicializado',
          'items': [
            {
              'material': 'Item de prueba (Base Inicializada)',
              'cantidad': 0,
            }
          ],
        });
      }
    } catch (e) {
      debugPrint("Error no bloqueante al sembrar la base de solicitudes: $e");
    }
  }

  // =========================================================================
  // MÉTODOS PRIVADOS AUXILIARES (Limpieza y Reglas de Negocio)
  // =========================================================================
  
  /// Sanitiza los datos provenientes de la interfaz dinámica de la vista.
  /// Previene errores de casteo (int/double) y filtra entradas vacías (Máximo 10 ítems).
  List<Map<String, dynamic>> _procesarYValidarItems(List<Map<String, dynamic>> items) {
    final filtrados = items.where((item) {
      final String? nombre = item['material']?.toString();
      return nombre != null && nombre.trim().isNotEmpty && nombre != 'Seleccionar';
    }).map((item) => {
      'material': item['material'] as String,
      'cantidad': int.tryParse(item['cantidad'].toString()) ?? 1,
    }).toList();

    if (filtrados.isEmpty) {
      throw Exception("No se puede procesar una solicitud sin insumos seleccionados.");
    }
    
    return filtrados;
  }

  // =========================================================================
  // CRUD TRADICIONAL: ABM del catálogo base de materiales
  // =========================================================================
  
  Future<void> agregarMaterial(MaterialModel material) async {
    try {
      await _materialesCollection.add(material.toMap());
    } catch (e) {
      debugPrint("Error al agregar material: $e");
      rethrow;
    }
  }

  Stream<List<MaterialModel>> obtenerMateriales() {
    return _materialesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MaterialModel.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id,
        );
      }).toList();
    });
  }

  Future<void> actualizarMaterial(String id, MaterialModel material) async {
    try {
      await _materialesCollection.doc(id).update(material.toMap());
    } catch (e) {
      debugPrint("Error al actualizar material: $e");
      rethrow;
    }
  }

  Future<void> eliminarMaterial(String id) async {
    try {
      await _materialesCollection.doc(id).delete();
    } catch (e) {
      debugPrint("Error al eliminar material: $e");
      rethrow;
    }
  }
}