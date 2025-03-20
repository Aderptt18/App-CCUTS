import 'package:cc_uts/views/principal/repositorio/SubirArchivo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class BuscarDocumentos extends StatefulWidget {
  @override
  _BuscarDocumentosState createState() => _BuscarDocumentosState();
}

class _BuscarDocumentosState extends State<BuscarDocumentos> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override

  
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función para descargar el PDF
  Future<void> _descargarPDF(String url, String fileName) async {
  // Solicitar permisos de almacenamiento
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Permisos de almacenamiento denegados')),
    );
    return;
  }

  // Obtener la ruta de la carpeta de descargas
  Directory? downloadsDir;
  if (Platform.isAndroid) {
    // En Android, usar la carpeta de descargas
    downloadsDir = Directory('/storage/emulated/0/Download');
  } else if (Platform.isIOS) {
    // En iOS, usar la carpeta de documentos
    downloadsDir = await getApplicationDocumentsDirectory();
  } else {
    // Fallback a la carpeta externa de almacenamiento
    downloadsDir = await getExternalStorageDirectory();
  }

  final path = downloadsDir?.path;

  if (path == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo acceder al almacenamiento')),
    );
    return;
  }

  // Descargar el archivo
  final taskId = await FlutterDownloader.enqueue(
    url: url,
    savedDir: path,
    fileName: fileName,
    showNotification: true,
    openFileFromNotification: true,
  );

  if (taskId != null) {
    // Mostrar mensaje informando al usuario que revise las notificaciones
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descarga iniciada. Revisa las notificaciones para ver el progreso.'),
        duration: Duration(seconds: 4),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al iniciar la descarga')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Repositorio'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar',
                filled: true,
                fillColor: Colors.green[100],
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Documentos')
                  .where('titulo', isGreaterThanOrEqualTo: _searchText)
                  .where('titulo', isLessThan: _searchText + 'z')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No se encontraron documentos'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var documento = snapshot.data!.docs[index];
                    var data = documento.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.description, color: Colors.white),
                        ),
                        title: Text(data['titulo'] ?? 'Sin título'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['autor'] ?? 'Autor desconocido'),
                            Text(data['institucion'] ?? 'Institución desconocida',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _mostrarDetallesDocumento(context, data);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubirDocumento()),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // Función para mostrar detalles del documento en un modal
  void _mostrarDetallesDocumento(BuildContext context, Map<String, dynamic> documento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
              padding: EdgeInsets.all(16),
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
                      margin: EdgeInsets.only(bottom: 16),
                    ),
                  ),
                  Text(
                    documento['titulo'] ?? 'Sin título',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Autor: ${documento['autor'] ?? 'Desconocido'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Institución: ${documento['institucion'] ?? 'Desconocida'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Descripción:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(documento['descripcion'] ?? 'Sin descripción'),
                  SizedBox(height: 16),
                  Text(
                    'Resumen:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(documento['resumen'] ?? 'Sin resumen'),
                  SizedBox(height: 16),
                  Text(
                    'Palabras clave:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(documento['palabras'] ?? 'Sin palabras clave'),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      // Obtener la URL del PDF y el nombre del archivo
                      String pdfUrl = documento['urlPdf'] ?? '';
                      String fileName = documento['pdf'] ?? 'documento.pdf';

                      // Descargar el PDF
                      _descargarPDF(pdfUrl, fileName);
                    },
                    icon: Icon(Icons.download),
                    label: Text('Descargar documento PDF'),
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
