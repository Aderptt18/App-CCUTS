import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Publicaciones extends StatelessWidget {
  const Publicaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Publicaciones')
            .orderBy('timestamp',
                descending: true) // Ordenar por fecha (más reciente primero)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No hay publicaciones disponibles.'));
          }

          final publicaciones = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: publicaciones.length,
            itemBuilder: (context, index) {
              final publicacion =
                  publicaciones[index].data() as Map<String, dynamic>;
              final nombreUsuario = publicacion['nombreUsuario'];
              final fotoUsuario = publicacion['fotoUsuario'];
              final mensaje = publicacion['mensaje'];
              final imagenUrl = publicacion['imagenUrl'];
              final chatActivo = publicacion['chatActivo'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto y nombre del usuario
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(fotoUsuario),
                            radius: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            nombreUsuario,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Mensaje de la publicación
                      Text(
                        mensaje,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),

                      // Imagen de la publicación (si existe)
                      if (imagenUrl != null && imagenUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: imagenUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),

                      // Botón de chat (si chatActivo es true)
                      if (chatActivo == true)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon:
                                const Icon(Icons.message, color: Colors.green),
                            onPressed: () {
                              // Navegar a la pantalla de chat
                              // Navigator.push(...);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
