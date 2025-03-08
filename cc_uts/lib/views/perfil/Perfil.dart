import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                _buildUserInfo(),
                _buildTabBar(),
                Expanded(
                  child: _buildTabContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  // Navegar a la pantalla de editar perfil
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarPerfil(userData: userData),
                    ),
                  ).then((_) => _loadUserData()); // Recargar datos después de editar
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.green,
            backgroundImage: userData!['imagen'] != null && userData!['imagen'].isNotEmpty
                ? NetworkImage(userData!['imagen'])
                : null,
            child: userData!['imagen'] == null || userData!['imagen'].isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Nombre', userData!['nombre'] ?? ''),
          _buildInfoRow('Correo', userData!['correo'] ?? ''),
          _buildInfoRow('Telefono', userData!['telefono'] ?? ''),
          _buildInfoRow('Carrera', userData!['carrera'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Row(
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
        // Contenido de pestaña "Mis publicaciones"
        _buildPublicacionesTab(),
        
        // Contenido de pestaña "Mis archivos"
        _buildArchivosTab(),
      ],
    );
  }

  Widget _buildPublicacionesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Publicaciones')
          .where('userId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay publicaciones disponibles'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var publicacion = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String mensaje = publicacion['mensaje'] ?? '';
            String titulo = publicacion['titulo'] ?? '';
            String? imageUrl = publicacion['imagenUrl'];

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
                    Text(mensaje),
                    if (imageUrl != null && imageUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
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

  Widget _buildArchivosTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Documentos')
          .where('uidUsuario', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay documentos disponibles'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var documento = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            
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
                  // Redirigir a la vista detallada del documento
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleDocumento(documento: documento),
                    ),
                  );
                },
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

// Widget para mostrar detalles del documento (implementación básica)
class DetalleDocumento extends StatelessWidget {
  final Map<String, dynamic> documento;

  const DetalleDocumento({Key? key, required this.documento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(documento['titulo'] ?? 'Detalle de documento'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              documento['titulo'] ?? 'Sin título',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Autor: ${documento['autor'] ?? 'No especificado'}'),
            Text('Institución: ${documento['institucion'] ?? 'No especificada'}'),
            const SizedBox(height: 20),
            const Text(
              'Resumen:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(documento['resumen'] ?? 'No hay resumen disponible'),
            const SizedBox(height: 20),
            const Text(
              'Palabras clave:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(documento['palabras'] ?? 'No hay palabras clave'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Aquí implementar la visualización del PDF
                // Puedes usar url_launcher o flutter_pdfview
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Ver PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}