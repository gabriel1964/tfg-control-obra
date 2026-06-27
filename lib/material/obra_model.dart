import 'package:cloud_firestore/cloud_firestore.dart';

class ObraModel {
  final String id;
  final String nombre;
  final String? estado; // Opcional: "En ejecución", "Finalizada", etc.
  final DateTime? fechaInicio; // Opcional: Para auditoría interna de la empresa

  const ObraModel({
    required this.id,
    required this.nombre,
    this.estado,
    this.fechaInicio,
  });

  /// Fábrica (Factory) para convertir un documento de Firebase Firestore 
  /// directamente en una instancia estructurada de ObraModel.
  factory ObraModel.fromFirestore(DocumentSnapshot doc) {
    // Salvaguarda segura en caso de que los datos vengan vacíos
    final data = doc.data() as Map<String, dynamic>?;

    return ObraModel(
      id: doc.id, // El ID se toma siempre del identificador del documento
      nombre: data?['nombre'] ?? 'Obra sin nombre especificado',
      estado: data?['estado'] ?? 'En ejecución',
      // Solución limpia: Evitamos usar "data!" y parseamos el Timestamp de forma segura
      fechaInicio: data?['fechaInicio'] != null 
          ? (data?['fechaInicio'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Método para convertir el modelo a un mapa JSON si en algún momento 
  /// la oficina central necesita registrar frentes de obra desde la app.
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      if (estado != null) 'estado': estado,
      if (fechaInicio != null) 'fechaInicio': Timestamp.fromDate(fechaInicio!),
    };
  }
}