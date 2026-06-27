import 'package:flutter/material.dart';
import 'package:flutter_tfg_1/views/widgets/custom_footer.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade700],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Contenedor del Logotipo Institucional
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(
                Icons.engineering_rounded,
                size: 80,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "SISTEMA DE SUPERVISIÓN",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Control de Asistencia y Materiales en Obra",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue.shade100, fontSize: 14),
            ),
            const Spacer(),
            // Botón de Acceso Principal
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text(
                  "INGRESAR AL SISTEMA",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Footer institucional integrado en el fondo oscuro
            const CustomFooter(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}