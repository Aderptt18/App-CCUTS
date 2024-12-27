import 'package:cc_uts/controllers/Pantallas.dart';
import 'package:flutter/material.dart';

class registro extends StatelessWidget {
  const registro({super.key});

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
                'assets/logo.png', // Ruta al logo en assets
                height: 120, // Altura del logo
              ),
            ),
            const SizedBox(height: 32), // Separador

            // Campo para ingresar el nombre
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

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
                // Acción al iniciar sesión
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pantallas()),
                );
              },
              child: const Text('Registrar'),
            ),

            // Separador
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
