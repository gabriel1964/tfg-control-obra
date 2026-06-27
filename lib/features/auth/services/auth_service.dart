import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escuchar si el supervisor está logueado o no
  Stream<User?> get supervisorState => _auth.authStateChanges();

  // Iniciar sesión con Email y Contraseña
  Future<User?> loginConEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Podés personalizar los mensajes de error según el código de Firebase
      throw Exception(_mapearErrorFirebase(e.code));
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapearErrorFirebase(String codigo) {
    switch (codigo) {
      case 'user-not-found':
        return 'No se encontró ningún supervisor con ese correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'user-disabled':
        return 'Este usuario ha sido deshabilitado.';
      default:
        return 'Error al intentar ingresar. Por favor, reintente.';
    }
  }
}