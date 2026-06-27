import 'package:cloud_firestore/cloud_firestore.dart';

class AsistenciaModel {
  final String id;
  final String obraId;
  final String operarioNombre;
  final DateTime fecha;
  final bool presente;

  AsistenciaModel({
    required this.id,
    required this.obraId,
    required this.operarioNombre,
    required this.fecha,
    required this.presente,
  });

  // Convertir de Objeto a JSON para Firebase
  Map<String, dynamic> toJson() {
    return {
      'obraId': obraId,
      'operarioNombre': operarioNombre,
      'fecha': Timestamp.fromDate(fecha), // Guardar como Timestamp nativo es mejor para ordenar
      'presente': presente,
    };
  }

  // Crear objeto desde Firebase de forma segura
  factory AsistenciaModel.fromJson(String id, Map<String, dynamic> json) {
    // 1. Manejo seguro del mapeo de la Fecha (soporta Timestamp y String)
    DateTime fechaParseada = DateTime.now(); 
    if (json['fecha'] != null) {
      if (json['fecha'] is Timestamp) {
        fechaParseada = (json['fecha'] as Timestamp).toDate();
      } else if (json['fecha'] is String) {
        fechaParseada = DateTime.tryParse(json['fecha']) ?? DateTime.now();
      }
    }

    // 2. Manejo seguro del booleano (soporta si quedó guardado como String "true" o booleano true)
    bool presenteParseado = false;
    if (json['presente'] != null) {
      if (json['presente'] is bool) {
        presenteParseado = json['presente'];
      } else if (json['presente'] is String) {
        presenteParseado = json['presente'].toString().toLowerCase() == 'true';
      }
    }

    return AsistenciaModel(
      id: id,
      obraId: json['obraId'] ?? '',
      // Mapea 'operarioNombre' o usa 'operario' como respaldo si ya tenés datos viejos guardados así
      operarioNombre: json['operarioNombre'] ?? json['operario'] ?? '',
      fecha: fechaParseada,
      presente: presenteParseado,
    );
  }
}