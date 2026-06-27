import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importamos tus vistas correspondientes
import 'login_view.dart'; // Asegurate de que tu pantalla de login se llame así en esa carpeta
import 'package:flutter_tfg_1/features/views/obra_selection_view.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Mientras Firebase comprueba el estado de la sesión
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // 2. Si el supervisor está logueado con éxito
        if (snapshot.hasData && snapshot.data != null) {
          return const ObraSelectionView();
        }
        
        // 3. Si no hay sesión activa, va al Login
        return const LoginView(); // Cambialo por el nombre exacto de tu widget de login si varía
      },
    );
  }
}