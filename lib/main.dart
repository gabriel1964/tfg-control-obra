import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Opciones autogeneradas de Firebase en la raíz de lib
import 'firebase_options.dart';

// Importaciones oficiales absolutas de tu arquitectura corregida
import 'features/auth/services/auth_service.dart';
import 'features/auth/views/welcome_view.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/terms_view.dart';
import 'features/views/obra_selection_view.dart';

// NUEVA IMPORTACIÓN: El guardián que maneja el estado de la sesión
import 'features/auth/views/auth_wrapper.dart';

// NUEVA INYECCIÓN: Para poder sembrar la colección transaccional al arrancar
import 'material/material_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. Inicializa la conexión con los servidores de Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // =========================================================================
    // NUEVA INYECCIÓN: Inicialización de la base de datos de solicitudes
    // =========================================================================
    final MaterialService materialService = MaterialService();
    await materialService.inicializarBaseSolicitudes();
    
  } catch (e) {
    debugPrint("Error crítico al inicializar Firebase o sembrar la base de datos: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFG Control de Obra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0F5EA3), // Azul institucional
      ),
      
      // 1. Definimos la ruta de entrada inicial de la App
      initialRoute: '/',
      
      // 2. Mapeo estructural de pantallas del módulo de acceso y gestión
      routes: {
        // La raíz ahora delega el control de flujo directamente al AuthWrapper
        '/': (context) => const AuthWrapper(),
            
        '/login': (context) => const LoginView(),
        '/terms': (context) => const TermsView(),
        '/obra-selection': (context) => const ObraSelectionView(),
      },
    );
  }
}