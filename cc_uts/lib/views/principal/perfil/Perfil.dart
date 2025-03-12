import 'package:cc_uts/views/principal/perfil/EditarPerfil.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                      builder: (context) =>EditarPerfilScreen(),
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
          // Puedes agregar más campos aquí y se desplazarán correctamente
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

        return ListView.builder(
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
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(publicacion['fotoUsuario'] ?? ''),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          publicacion['nombreUsuario'] ?? 'Usuario',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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

        return ListView.builder(
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
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(documento['descripcion'] ?? 'Sin descripción'),
                    Text(documento['institucion'] ?? 'Sin institución'),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
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
                  Text(
                    documento['titulo'] ?? 'Sin título',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

// Widget de editar perfil (implementación básica)
class EditarPerfil extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const EditarPerfil({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Aquí va el formulario para editar el perfil'),
      ),
    );
  }
}