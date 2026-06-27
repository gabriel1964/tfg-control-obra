# Plataforma de Supervisión en Tiempo Real para Entornos de Obra

Prototipo funcional desarrollado como Trabajo de Final de Grado (TFG) para la Licenciatura en Informática de la Universidad Siglo 21. La plataforma está diseñada para digitalizar y optimizar los procesos manuales de control de asistencia y gestión de materiales en frentes de obra electromecánicos y eléctricos.

---

## 🚀 Enlaces del Proyecto

*   **Aplicación Web en Producción:** [https://tfg-control-obra.web.app](https://tfg-control-obra.web.app)
*   **Código Fuente (Repositorio Oficial):** [https://github.com/Gabriel1964a/tfg-control-obra](https://github.com/Gabriel1964a/tfg-control-obra)

---

## 🛠️ Tecnologías Utilizadas

*   **Frontend:** Flutter Framework & Dart Programming Language (Orientado a entorno Web responsivo).
*   **Backend & Base de Datos:** Google Firebase & Cloud Firestore (Arquitectura serverless con sincronización en tiempo real).
*   **Autenticación:** Firebase Authentication (Control de acceso basado en roles).
*   **Metodología de Desarrollo:** Scrum.

---

## 📂 Estructura del Proyecto (`lib/`)

La arquitectura del código fuente sigue un patrón modular estructurado por características (*features*), servicios y vistas específicas para el flujo de trabajo del supervisor en obra:

*   **`asistencia/`**: Gestión integral del presentismo de los operarios.
    *   `asistencia_form_view.dart`: Formulario dinámico para la toma de asistencia.
    *   `asistencia_history_view.dart` / `asistencia_list_view.dart`: Visualización histórica y listado de registros del día.
    *   `asistencia_model.dart`: Modelo de datos de asistencias con soporte nativo de marcas temporales.
    *   `asistencia_service.dart`: Integración directa con las colecciones de Firestore.
*   **`features/auth/`**: Módulo seguro de control de acceso.
    *   `auth_service.dart`: Lógica de inicio y cierre de sesión de usuarios.
    *   `auth_wrapper.dart`: Enrutador dinámico del estado de la autenticación.
    *   `login_view.dart` / `welcome_view.dart` / `terms_view.dart`: Interfaces gráficas de acceso y validación de TyC.
*   **`material/`**: Módulo para la trazabilidad de insumos y solicitudes.
    *   `material_form_view.dart` / `material_request_view.dart`: Gestión interactiva de solicitudes de materiales en obra.
    *   `material_history_view.dart` / `material_list_view.dart`: Historial de pedidos y estados de rezago de insumos.
    *   `material_model.dart` / `material_service.dart`: Estructura de datos y persistencia en la base de datos NoSQL.
*   **`services/` & `views/` generales**:
    *   `obra_service.dart` / `obra_selection_view.dart`: Lógica para la conmutación dinámica entre diferentes frentes de obra activos.
    *   `supervisor_panel_view.dart`: Panel centralizado de control operado exclusivamente por el supervisor a cargo.
    *   `firebase_options.dart`: Configuraciones de inicialización de los servicios de la nube de Firebase.
    *   `main.dart`: Punto de entrada principal y configuración inicial de la aplicación.

---

## ⚙️ Características Clave Implementadas

1.  **Rol Único de Operación:** Interfaz optimizada para el uso exclusivo por parte del Supervisor de Obra, mitigando errores de carga en entornos de alta exigencia.
2.  **Sincronización en Tiempo Real:** El registro de asistencia e insumos impacta de forma inmediata en la base de datos sin necesidad de recargas manuales.
3.  **Trazabilidad de Materiales:** Flujo dinámico de solicitudes limitado para optimizar la cadena de abastecimiento y reducir el rezago físico en los frentes de trabajo.
4.  **Enfoque de Movilidad Pura:** Diseñado para funcionar de manera ágil desde cualquier navegador móvil en el terreno de la obra sin depender de coordenadas geográficas ni rastreos invasivos.

---

## 📊 Autores y Contexto Académico

*   **Institución:** Universidad Siglo 21 (Córdoba, Argentina).
*   **Carrera:** Licenciatura en Informática.
*   **Contexto de Aplicación:** Automatización y digitalización para entornos de infraestructura y construcción.
