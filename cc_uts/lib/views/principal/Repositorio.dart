import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';

class Repositorio extends StatefulWidget {
  const Repositorio({super.key});

  @override
  State<Repositorio> createState() => _RepositorioState();
}

class _RepositorioState extends State<Repositorio> {
  final Map<String, bool> _expandedStates = {}; // Para controlar el estado de "Leer más..."

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones'),
        backgroundColor: const Color(0xFFB8E6B9),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Publicaciones')
            .orderBy('timestamp', descending: true) // Ordenar por fecha (más reciente primero)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay publicaciones disponibles.'));
          }

          final publicaciones = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: publicaciones.length,
            itemBuilder: (context, index) {
              final publicacion = publicaciones[index].data() as Map<String, dynamic>;
              final publicacionId = publicaciones[index].id; // ID de la publicación
              final nombreUsuario = publicacion['nombreUsuario'];
              final fotoUsuario = publicacion['fotoUsuario'];
              final mensaje = publicacion['mensaje'];
              final imagenUrl = publicacion['imagenUrl'];
              final chatActivo = publicacion['chatActivo'];

              // Inicializar el estado de "Leer más..." si no existe
              _expandedStates.putIfAbsent(publicacionId, () => false);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: const Color(0xFFB8E6B9), // Color de fondo del cuadro
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto y nombre del usuario
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(fotoUsuario),
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

                      // Mensaje de la publicación con "Leer más..." integrado
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final text = mensaje;
                          final isExpanded = _expandedStates[publicacionId]!;
                          final maxLength = 200; // Longitud inicial del texto

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: isExpanded
                                          ? text
                                          : (text.length > maxLength
                                              ? '${text.substring(0, maxLength)}... '
                                              : text),
                                    ),
                                    if (text.length > maxLength)
                                      TextSpan(
                                        text: isExpanded ? 'Leer menos' : 'Leer más...',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            setState(() {
                                              _expandedStates[publicacionId] = !isExpanded;
                                            });
                                          },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
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
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),

                      // Botón de chat (si chatActivo es true)
                      if (chatActivo == true)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: const Icon(Icons.message, color: Colors.green),
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