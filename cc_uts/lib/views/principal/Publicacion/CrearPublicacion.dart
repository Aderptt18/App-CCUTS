import 'package:cc_uts/controlador/Imagenes/SeleccionarImagen.dart';
import 'package:cc_uts/controlador/Imagenes/SubirImagenFirebase.dart';
import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class CrearPublicacion extends StatefulWidget {
  const CrearPublicacion({super.key});

  @override
  State<CrearPublicacion> createState() => _CrearPublicacionState();
}

class _CrearPublicacionState extends State<CrearPublicacion> {
  bool _chat = false;
  bool _isLoading = false;
  File? _image;
  String? _imageUrl;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void updateUrl(String url) {
    setState(() => _imageUrl = url);
  }

  Future<void> _handleImageSelection() async {
    final XFile? image = await getImage();
    if (image != null) {
      setState(() => _image = File(image.path));
    }
  }

  void _removeImage() {
    setState(() => _image = null);
  }

  Future<String> _nombreUsuario() async {
    String? uid = await AlmacenamientoUid.getUID();
    if (uid != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['nombre'] ?? '';
      }
    }
    return '';
  }

  void _crearChat() {
    setState(() => _chat = !_chat);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _chat ? 'Se ha generado el chat correctamente!!!' : 'Chat desactivado',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFB8E6B9),
      ),
    );
  }

  Future<void> _publish() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_image != null) {
        await subirImagenPublicacion(_image!, updateUrl, _titleController);
      }

      String? _uid = await AlmacenamientoUid.getUID();
      if (_uid == null) {
        throw Exception("No se pudo obtener el UID del usuario");
      }

      DocumentReference publicacionRef = await FirebaseFirestore.instance
          .collection('Publicaciones')
          .add({
        'titulo': _titleController.text,
        'mensaje': _messageController.text,
        'imagenUrl': _imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': _uid,
        'nombreUsuario': await _nombreUsuario(),
        'chatActivo': _chat,
      });

      String publicacionId = publicacionRef.id;

      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(_uid)
          .update({
        'publicaciones': FieldValue.arrayUnion([publicacionId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Publicación creada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al publicar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    _titleController.clear();
    _messageController.clear();
    setState(() => _image = null);
  }

  Widget _buildImagePicker() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Color(0xFFB8E6B9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                _image!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_image != null)
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                    onPressed: _removeImage,
                  ),
                SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Color(0xFF4CAF50),
                  child: Icon(Icons.image, color: Colors.white),
                  onPressed: _handleImageSelection,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50),
        elevation: 0,
        title: Text('Crear publicación'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Título...',
                  filled: true,
                  fillColor: Color(0xFFB8E6B9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: null,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Mensaje...',
                  filled: true,
                  fillColor: Color(0xFFB8E6B9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: null,
              ),
              SizedBox(height: 16),
              _buildImagePicker(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _crearChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _chat ? Color(0xFF4CAF50) : Color(0xFFB8E6B9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child:
                    Text('Crear chat', style: TextStyle(color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 100),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _publish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Icon(Icons.send, color: Colors.black),
                  label:
                      Text('PUBLICAR', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}