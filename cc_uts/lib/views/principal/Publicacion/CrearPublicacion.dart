import 'package:cc_uts/controlador/Imagenes/SeleccionarImagen.dart';
import 'package:cc_uts/controlador/Imagenes/SubirImagenFirebase.dart';
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

  void _crearChat() {
    setState(() {
      _chat = !_chat;
    });
    if (_chat) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text(
          'Se ha generado el chat correctamente!!!',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFB8E6B9)),
      );
    }
  }

  Future<void> _publish() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty)
      return;

    try {
      if (_image != null) {
        await subirImagenPublicacion(_image!, updateUrl, _titleController);
      }

      await FirebaseFirestore.instance.collection('Publicaciones').add({
        'titulo': _titleController.text,
        'mensaje': _messageController.text,
        'imagenUrl': _imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': 'CURRENT_USER_ID',
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Se ha publicado correctamente'),
            backgroundColor: Color(0xFFB8E6B9)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al publicar, intentalo de nuevo'),
            backgroundColor: Colors.red),
      );
    }
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
                  hintText: 'Titulo...',
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
              Container(
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
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Color(0xFFB8E6B9),
                        child: Icon(Icons.image),
                        onPressed: _handleImageSelection,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _crearChat();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _chat
                      ? Color.fromARGB(255, 86, 220, 88)
                      : Color(0xFFB8E6B9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child:
                    Text('Crear chat', style: TextStyle(color: Colors.black)),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: ElevatedButton(
                      onPressed: _publish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text('PUBLICAR', style: TextStyle(color: Colors.black)))),
            ],
          ),
        ),
      ),
    );
  }
}
