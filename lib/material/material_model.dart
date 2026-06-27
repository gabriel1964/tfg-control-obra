class MaterialModel {
  final String? id; // El ID que genera Firebase automáticamente
  final String nombre;
  final double cantidad;
  final String unidadMedida; // Ej: 'Bolsas', 'Metros', 'Ud.'
  final String? proveedor;

  MaterialModel({
    this.id,
    required this.nombre,
    required this.cantidad,
    required this.unidadMedida,
    this.proveedor,
  });

  // 1. Convierte un objeto MaterialModel a un Mapa (JSON) para subirlo a Firebase (Create/Update)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
      'unidadMedida': unidadMedida,
      'proveedor': proveedor,
    };
  }

  // 2. Recibe un mapa de Firebase y lo transforma en un objeto MaterialModel para usarlo en Flutter (Read)
  factory MaterialModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MaterialModel(
      id: documentId,
      nombre: map['nombre'] ?? '',
      cantidad: (map['cantidad'] ?? 0).toDouble(),
      unidadMedida: map['unidadMedida'] ?? '',
      proveedor: map['proveedor'],
    );
  }
}