import 'package:cc_uts/controllers/Pantallas.dart';
import 'package:cc_uts/views/autentificacion/Registro.dart';
import 'package:flutter/material.dart';

class Acceso extends StatelessWidget {
  const Acceso({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo en la parte superior
            Center(
              child: Image.asset(
                'assets/Inicio App.png', // Ruta al logo en assets
                height: 120, // Altura del logo
              ),
            ),
            const SizedBox(height: 32), // Separador

            // Campo para ingresar el correo
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            // Campo para ingresar la contraseña
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),

            // Botón de iniciar sesión
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pantallas()),
                );
              },
              child: Text('Iniciar Sesión'),
            ),

            // Separador
            const SizedBox(height: 16),

            // Texto adicional para registrar o recuperar contraseña
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('¿No tienes cuenta?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => registro()),
                    );
                  },
                  child: const Text('Regístrate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
