import 'package:cc_uts/views/principal/perfil/EditarPerfil.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({Key? key}) : super(key: key);

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? uid;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isDeletingPublication = false;
  bool isDeletingDocument = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Map<String, bool> _expandedStates = {}; // Para controlar el estado de "Leer más..."

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      uid = await AlmacenamientoUid.getUID();
      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Función para eliminar una publicación
  Future<void> _eliminarPublicacion(String publicacionId, String? imagenUrl) async {
    setState(() {
      isDeletingPublication = true;
    });
    
    try {
      // 1. Eliminar la imagen de Firebase Storage si existe
      if (imagenUrl != null && imagenUrl.isNotEmpty) {
        try {
          // Obtener la referencia de la imagen en Firebase Storage
          final ref = FirebaseStorage.instance.refFromURL(imagenUrl);
          await ref.delete();
        } catch (e) {
          print('Error al eliminar la imagen: $e');
          // Continuamos con el proceso aunque la imagen no se pueda eliminar
        }
      }

      // 2. Eliminar el documento de la colección Publicaciones
      await FirebaseFirestore.instance
          .collection('Publicaciones')
          .doc(publicacionId)
          .delete();

      // 3. Actualizar el array de publicaciones del usuario
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(uid)
            .update({
          'publicaciones': FieldValue.arrayRemove([publicacionId]),
        });
      }

      // 4. Recargar los datos del usuario
      await _loadUserData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicación eliminada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al eliminar la publicación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la publicación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDeletingPublication = false;
        });
      }
    }
  }

  // Función para eliminar un documento/archivo
  Future<void> _eliminarDocumento(String documentoId, String? pdfUrl) async {
    setState(() {
      isDeletingDocument = true;
    });
    
    try {
      // 1. Eliminar el PDF de Firebase Storage si existe
      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        try {
          // Obtener la referencia del PDF en Firebase Storage
          final ref = FirebaseStorage.instance.refFromURL(pdfUrl);
          await ref.delete();
        } catch (e) {
          print('Error al eliminar el PDF: $e');
          // Continuamos con el proceso aunque el PDF no se pueda eliminar
        }
      }

      // 2. Eliminar el documento de la colección Documentos
      await FirebaseFirestore.instance
          .collection('Documentos')
          .doc(documentoId)
          .delete();

      // 3. Actualizar el array de misArchivos del usuario
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(uid)
            .update({
          'misArchivos': FieldValue.arrayRemove([documentoId]),
        });
      }

      // 4. Recargar los datos del usuario
      await _loadUserData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documento eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al eliminar el documento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el documento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDeletingDocument = false;
        });
      }
    }
  }

  // Función para mostrar diálogo de confirmación antes de eliminar
  Future<bool> _confirmarEliminacion(String tipo) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar $tipo'),
        content: Text('¿Estás seguro de que deseas eliminar este $tipo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  // Función para cerrar sesión
  Future<void> signOut() async {
    await AlmacenamientoUid.removeUID();
    await _firebaseAuth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        automaticallyImplyLeading: false, // Elimina el botón de retroceso
        toolbarHeight: 40, // AppBar más pequeño
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: signOut,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: _buildUserInfo(),
                  ),
                ),
                _buildTabBar(),
                Expanded(
                  flex: 2,
                  child: _buildTabContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green,
                    backgroundImage: userData!['imagen'] != null && userData!['imagen'].isNotEmpty
                        ? CachedNetworkImageProvider(userData!['imagen']) as ImageProvider
                        : null,
                    child: userData!['imagen'] == null || userData!['imagen'].isEmpty
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarPerfilScreen(),
                    ),
                  ).then((_) => _loadUserData());
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.green[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Nombre', userData!['nombre'] ?? ''),
          _buildInfoRow('Correo', userData!['correo'] ?? ''),
          _buildInfoRow('Telefono', userData!['telefono'] ?? ''),
          _buildInfoRow('Carrera', userData!['carrera'] ?? ''),
          if (userData!.containsKey('semestre'))
            _buildInfoRow('Semestre', userData!['semestre'] ?? ''),
          if (userData!.containsKey('direccion'))
            _buildInfoRow('Dirección', userData!['direccion'] ?? ''),
          if (userData!.containsKey('biografia'))
            _buildInfoRow('Biografía', userData!['biografia'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinea al principio para textos largos
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.green,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            child: Text(
              'Mis publicaciones',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Tab(
            child: Text(
              'Mis archivos',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPublicacionesTab(),
        _buildArchivosTab(),
      ],
    );
  }

  Widget _buildPublicacionesTab() {
    // Verificamos que userData y publicaciones existan
    if (userData == null || !userData!.containsKey('publicaciones')) {
      return const Center(child: Text('No hay publicaciones disponibles'));
    }

    List<dynamic> publicaciones = userData!['publicaciones'] ?? [];
    
    if (publicaciones.isEmpty) {
      return const Center(child: Text('No hay publicaciones disponibles'));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _obtenerPublicaciones(publicaciones),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay publicaciones disponibles'));
        }

        List<Map<String, dynamic>> publicacionesData = snapshot.data!;

        return isDeletingPublication
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: publicacionesData.length,
                itemBuilder: (context, index) {
                  var publicacion = publicacionesData[index];
                  String mensaje = publicacion['mensaje'] ?? '';
                  String titulo = publicacion['titulo'] ?? '';
                  String? imageUrl = publicacion['imagenUrl'];
                  String publicacionId = publicacion['id'];
                  
                  // Inicializar el estado de "Leer más..." si no existe
                  _expandedStates.putIfAbsent(publicacionId, () => false);
                  final isExpanded = _expandedStates[publicacionId]!;
                  final maxLength = 200; // Longitud inicial del texto

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.green[100],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // FIX 1: Wrapped this Row with Expanded to prevent overflow
                              Expanded(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: userData!['imagen'] != null && userData!['imagen'].isNotEmpty
                                          ? CachedNetworkImageProvider(userData!['imagen']) as ImageProvider
                                          : null,
                                      radius: 20,
                                      child: userData!['imagen'] == null || userData!['imagen'].isEmpty
                                          ? const Icon(Icons.person, size: 20, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    // FIX 2: Wrapped the Text with Expanded to handle long names
                                    Expanded(
                                      child: Text(
                                        userData!['nombre'] ?? 'Usuario',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis, // Add ellipsis for long text
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  if (await _confirmarEliminacion('publicación')) {
                                    await _eliminarPublicacion(publicacionId, imageUrl);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (titulo.isNotEmpty)
                            Text(
                              titulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          const SizedBox(height: 8),
                          // Mensaje con "Leer más..." implementado
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: isExpanded
                                    ? mensaje
                                    : (mensaje.length > maxLength
                                        ? '${mensaje.substring(0, maxLength)}... '
                                        : mensaje),
                                ),
                                if (mensaje.length > maxLength)
                                  TextSpan(
                                    text: isExpanded ? 'Leer menos' : ' Leer más...',
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
                          if (imageUrl != null && imageUrl.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.green[300],
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _obtenerPublicaciones(List<dynamic> publicacionesIds) async {
    List<Map<String, dynamic>> resultado = [];
    
    for (String id in publicacionesIds) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Publicaciones')
            .doc(id)
            .get();
            
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          resultado.add(data);
        }
      } catch (e) {
        print('Error al obtener publicación $id: $e');
      }
    }
    
    // Ordenar por timestamp (más reciente primero)
    resultado.sort((a, b) {
      Timestamp timestampA = a['timestamp'] ?? Timestamp.now();
      Timestamp timestampB = b['timestamp'] ?? Timestamp.now();
      return timestampB.compareTo(timestampA);
    });
    
    return resultado;
  }

  Widget _buildArchivosTab() {
    // Verificamos que userData y misArchivos existan
    if (userData == null || !userData!.containsKey('misArchivos')) {
      return const Center(child: Text('No hay documentos disponibles'));
    }

    List<dynamic> archivos = userData!['misArchivos'] ?? [];
    
    if (archivos.isEmpty) {
      return const Center(child: Text('No hay documentos disponibles'));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _obtenerArchivos(archivos),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay documentos disponibles'));
        }

        List<Map<String, dynamic>> archivosData = snapshot.data!;

        return isDeletingDocument
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: archivosData.length,
                itemBuilder: (context, index) {
                  var documento = archivosData[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    color: Colors.green[100],
                    child: ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.green,
                        size: 40,
                      ),
                      title: Text(
                        documento['titulo'] ?? 'Sin título',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // FIX 3: Add ellipsis for long titles
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            documento['descripcion'] ?? 'Sin descripción',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // FIX 4: Add ellipsis for long descriptions
                          ),
                          Text(
                            documento['institucion'] ?? 'Sin institución',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // FIX 5: Add ellipsis for long institution names
                          ),
                        ],
                      ),
                      // FIX 6: Remove the Row in trailing and use IconButton directly
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (await _confirmarEliminacion('documento')) {
                            await _eliminarDocumento(documento['id'], documento['urlPdf']);
                          }
                        },
                      ),
                      onTap: () {
                        _mostrarDetallesDocumento(context, documento);
                      },
                    ),
                  );
                },
              );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _obtenerArchivos(List<dynamic> archivosIds) async {
    List<Map<String, dynamic>> resultado = [];
    
    for (String id in archivosIds) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Documentos')
            .doc(id)
            .get();
            
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          resultado.add(data);
        }
      } catch (e) {
        print('Error al obtener archivo $id: $e');
      }
    }
    
    // Ordenar por timestamp (más reciente primero)
    resultado.sort((a, b) {
      Timestamp timestampA = a['timestamp'] ?? Timestamp.now();
      Timestamp timestampB = b['timestamp'] ?? Timestamp.now();
      return timestampB.compareTo(timestampA);
    });
    
    return resultado;
  }
  
  // Función para mostrar detalles del documento en un modal
  void _mostrarDetallesDocumento(BuildContext context, Map<String, dynamic> documento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          documento['titulo'] ?? 'Sin título',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          Navigator.pop(context); // Cerrar el modal
                          if (await _confirmarEliminacion('documento')) {
                            await _eliminarDocumento(documento['id'], documento['urlPdf']);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Autor: ${documento['autor'] ?? 'Desconocido'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Institución: ${documento['institucion'] ?? 'Desconocida'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Descripción:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(documento['descripcion'] ?? 'Sin descripción'),
                  const SizedBox(height: 16),
                  const Text(
                    'Resumen:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(documento['resumen'] ?? 'Sin resumen'),
                  const SizedBox(height: 16),
                  const Text(
                    'Palabras clave:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(documento['palabras'] ?? 'Sin palabras clave'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      // Implementar la visualización del PDF
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Ver PDF'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}