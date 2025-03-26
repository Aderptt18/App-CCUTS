import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';

class Publicaciones extends StatelessWidget {
  const Publicaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Publicaciones')
            .orderBy('timestamp', descending: true)
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
              final publicacionId = publicaciones[index].id;
              final userId = publicacion['userId'];
              final mensaje = publicacion['mensaje'];
              final imagenUrl = publicacion['imagenUrl'];

              // Cada publicación es un widget independiente con su propio estado
              return PublicacionCard(
                publicacionId: publicacionId,
                userId: userId,
                mensaje: mensaje,
                imagenUrl: imagenUrl,
              );
            },
          );
        },
      ),
    );
  }
}

// Nuevo widget para cada publicación individual
class PublicacionCard extends StatefulWidget {
  final String publicacionId;
  final String userId;
  final String mensaje;
  final String? imagenUrl;

  const PublicacionCard({
    super.key,
    required this.publicacionId,
    required this.userId,
    required this.mensaje,
    this.imagenUrl,
  });

  @override
  State<PublicacionCard> createState() => _PublicacionCardState();
}

class _PublicacionCardState extends State<PublicacionCard> {
  bool _isExpanded = false;

  Future<Map<String, dynamic>> _obtenerDatosUsuario(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        return {
          'nombreUsuario': userData['nombre'] ?? 'Usuario',
          'fotoUsuario': userData['imagen'] ?? '',
        };
      }
      return {'nombreUsuario': 'Usuario', 'fotoUsuario': ''};
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return {'nombreUsuario': 'Usuario', 'fotoUsuario': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _obtenerDatosUsuario(widget.userId),
      builder: (context, userSnapshot) {
        // Datos del usuario
        final nombreUsuario =
            userSnapshot.data?['nombreUsuario'] ?? 'Cargando...';
        final fotoUsuario = userSnapshot.data?['fotoUsuario'] ?? '';

        // Widget para mostrar foto de perfil con fallback
        Widget profileImageWidget = CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          child: fotoUsuario.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: fotoUsuario,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person),
                  ),
                )
              : const Icon(Icons.person),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: const Color(0xFFB8E6B9),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto y nombre del usuario
                Row(
                  children: [
                    profileImageWidget,
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

                // Mensaje de la publicación con "Leer más..."
                LayoutBuilder(
                  builder: (context, constraints) {
                    final text = widget.mensaje;
                    final maxLength = 200;

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
                                text: _isExpanded
                                    ? text
                                    : (text.length > maxLength
                                        ? '${text.substring(0, maxLength)}... '
                                        : text),
                              ),
                              if (text.length > maxLength)
                                TextSpan(
                                  text: _isExpanded
                                      ? 'Leer menos'
                                      : 'Leer más...',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      setState(() {
                                        _isExpanded = !_isExpanded;
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
                if (widget.imagenUrl != null && widget.imagenUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.imagenUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}