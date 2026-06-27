import 'package:flutter/material.dart';
import 'package:flutter_tfg_1/views/widgets/custom_footer.dart';

class TermsView extends StatefulWidget {
  const TermsView({super.key});

  @override
  State<TermsView> createState() => _TermsViewState();
}

class _TermsViewState extends State<TermsView> {
  bool _hasAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBFF),
        title: const Text(
          "Declaración de Responsabilidad", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
        ),
        automaticallyImplyLeading: false, 
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.gavel_rounded, 
                        size: 60, 
                        color: Color(0xFFFF6D00)
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Términos de Uso y Protección de Datos",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Por favor, lea atentamente la declaración legal antes de operar el aplicativo en entorno de producción.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Text(
                        "1. MARCO DE AUDITORÍA Y SEGURIDAD\n"
                        "El usuario autenticado en calidad de Supervisor asume la responsabilidad legal y administrativa de los datos volcados en este sistema. El ingreso manual de asistencia del personal y los pedidos de insumos serán considerados declaraciones juradas de avance de obra en tiempo real.\n\n"
                        "2. PROTECCIÓN DE DATOS PERSONALES\n"
                        "En concordancia con las leyes vigentes de protección de datos personales, queda estrictamente prohibida la divulgación, exportación no autorizada o manipulación maliciosa del padrón de personal operativo asignado a los frentes de trabajo. El acceso a la información se rige bajo principios de estricta necesidad corporativa.\n\n"
                        "3. LOGS Y TRAZABILIDAD\n"
                        "Cada transacción, confirmación de asistencia o requisición de materiales almacena de forma inalterable el ID de usuario del supervisor, timestamp y metadatos de red para auditorías de sistemas posteriores. Cualquier inconsistencia severa será reportada al área de control de gestión.",
                        style: TextStyle(fontSize: 13, height: 1.6, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text(
                        "Acepto los términos, condiciones y la política de resguardo de datos institucionales.",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      value: _hasAccepted,
                      activeColor: const Color(0xFF0F5EA3),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) => setState(() => _hasAccepted = val ?? false),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6D00),
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        onPressed: _hasAccepted 
                            ? () {
                                // Limpieza del stack y navegación directa a la selección de frentes de obra activos
                                Navigator.pushNamedAndRemoveUntil(context, '/obra-selection', (route) => false);
                              }
                            : null,
                        child: const Text("CONTINUAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }
}