import 'package:flutter/material.dart';

class CrearPublicacion extends StatelessWidget {
  const CrearPublicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Publicación'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Necesito ayuda con mi proyecto sobre el cambio climático...',
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Add image button
            ElevatedButton.icon(
              onPressed: () {
                // Implementar agregar imagen
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar imagen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[200],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),
            
            // Generate chat option
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implementar generar chat
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[200],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Generar Chat'),
                ),
                const SizedBox(width: 20),
                Checkbox(
                  value: false,
                  onChanged: (value) {
                    // Implementar checkbox
                  },
                ),
              ],
            ),
            
            const Spacer(),
            
            // Publish button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implementar publicar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Publicar', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}