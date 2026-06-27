import 'package:cloud_firestore/cloud_firestore.dart';
import 'asistencia_model.dart';

class AsistenciaService {
  // Instancia de Firebase Firestore para interactuar con la base de datos
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 1. Registrar una nueva asistencia en la colección 'asistencias'
  Future<void> registrarAsistencia(AsistenciaModel asistencia) async {
    try {
      await _db.collection('asistencias').add(asistencia.toJson());
    } catch (e) {
      throw Exception('Error al registrar la asistencia en Firestore: $e');
    }
  }

  /// 2. Obtener el historial de asistencias en tiempo real (Stream) filtrado por Obra
  /// Ordena los registros para que los más recientes aparezcan primero en la lista
  Stream<List<AsistenciaModel>> getHistorialAsistencias(String obraId) {
    return _db
        .collection('asistencias')
        .where('obraId', isEqualTo: obraId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AsistenciaModel.fromJson(doc.id, doc.data());
          }).toList();
        });
  }

  /// 3. Obtener la lista de nombres de operarios asignados a una obra específica
  /// MODIFICADO: Ahora busca en la colección independiente 'operarios' filtrando por 'obraId'
  Future<List<String>> getOperariosPorObra(String obraId) async {
    try {
      // LINEA DE DEPURACIÓN: Te permite verificar en consola qué ID estás mandando desde la vista
      print("DEBUG: Buscando operarios en Firestore con el obraId -> '$obraId'");

      QuerySnapshot snapshot = await _db
          .collection('operarios')
          .where('obraId', isEqualTo: obraId)
          .get();

      // Mapeamos los documentos para extraer únicamente el campo string 'nombre'
      List<String> listaOperarios = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['nombre'] as String;
      }).toList();

      print("DEBUG: Operarios encontrados -> ${listaOperarios.length}");
      return listaOperarios;
    } catch (e) {
      throw Exception('Error al obtener la lista de operarios desde la colección: $e');
    }
  }
}