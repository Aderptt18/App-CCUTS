# cc_uts

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

flutter pub run change_app_package_name:main com.CCUTS




estructura de los archivos:
lib/
├── main.dart                # Punto de entrada de la app
├── app/
│   ├── app.dart             # Configuración de la aplicación (tema, rutas)
│   ├── routes.dart          # Rutas de navegación
├── controllers/             # Controladores para manejar lógica de cada pantalla
│   ├── home_controller.dart
│   ├── profile_controller.dart
│   ├── chat_controller.dart
│   ├── repository_controller.dart
│   ├── posts_controller.dart
│   ├── settings_controller.dart
├── models/                  # Modelos de datos compartidos entre vistas y controladores
│   ├── user_model.dart
│   ├── post_model.dart
│   ├── repository_model.dart
├── views/                   # Pantallas (Vistas) de tu aplicación
│   ├── home/
│   │   ├── home_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   ├── chat/
│   │   ├── chat_screen.dart
│   ├── repository/
│   │   ├── repository_screen.dart
│   ├── posts/
│   │   ├── posts_screen.dart
│   ├── settings/
│       ├── settings_screen.dart
├── widgets/                 # Widgets reutilizables
│   ├── custom_button.dart
│   ├── custom_card.dart
│   ├── bottom_nav_bar.dart  # Widget de BottomNavigationBar
├── services/                # Servicios externos o internos (API, Firebase)
│   ├── firebase_service.dart
│   ├── api_service.dart
├── utils/                   # Utilidades y constantes
│   ├── constants.dart       # Colores, tamaños, etc.
│   ├── helpers.dart         # Métodos de utilidad
