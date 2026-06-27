import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tfg_1/material/obra_model.dart';

class ObraService {
  final CollectionReference _obrasCollection = 
      FirebaseFirestore.instance.collection('obras');

  /// Recupera todas las obras de Firestore y las transforma en una lista de objetos ObraModel
  Future<List<ObraModel>> obtenerObras() async {
    try {
      QuerySnapshot querySnapshot = await _obrasCollection.get();
      
      // Delegamos el mapeo al factory del modelo, manteniendo el código limpio y mantenible
      return querySnapshot.docs.map((doc) {
        return ObraModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('Error al cargar las obras desde Cloud Firestore: $e');
    }
  }
}