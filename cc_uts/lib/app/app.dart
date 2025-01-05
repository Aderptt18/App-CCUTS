import 'package:cc_uts/controlador/Acceso.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Pantalla inicial
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Configuración del controlador de animación
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duración del zoom
    )..forward();

    // Temporizador para redirigir después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Acceso()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Fondo blanco
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + _controller.value * 0.2, // Efecto de zoom
                child: Image.asset(
                  'assets/Inicio App.png', // Imagen de assets
                  fit: BoxFit.cover, // Ajusta la imagen para llenar la pantalla
                  width: double.infinity, // Ancho completo
                  height: double.infinity, // Alto completo
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
