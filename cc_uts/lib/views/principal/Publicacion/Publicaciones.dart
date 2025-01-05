import 'package:flutter/material.dart';

class Publicaciones extends StatelessWidget {
  const Publicaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: 1, // Ejemplo con una publicación
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            color: Colors.green[200],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Juan Pérez',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Content
                  const Text('Necesito ayuda con mi proyecto sobre el cambio climático, no he podido realizarlo por motivos de falta de información'),
                  const SizedBox(height: 12),
                  
                  // Image placeholder
                  Container(
                     height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, size: 50),
                  ),
                  
                  // Interaction buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_comment),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_up_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}