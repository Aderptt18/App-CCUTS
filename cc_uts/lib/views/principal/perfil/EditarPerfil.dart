import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:cc_uts/controlador/Imagenes/SeleccionarImagen.dart';
import 'package:cc_uts/controlador/Imagenes/SubirImagenFirebase.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({Key? key}) : super(key: key);

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final TextEditingController _controllerNombre = TextEditingController();
  final TextEditingController _controllerTelefono = TextEditingController();
  final TextEditingController _controllerCarrera = TextEditingController();
  
  String? imageUrl;
  String? currentImageUrl;
  File? _selectedImage;
  bool _isLoading = true;
  String? userId;
  
  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }
  
  Future<void> _cargarDatosUsuario() async {
    try {
      userId = await AlmacenamientoUid.getUID();
      if (userId == null) {
        _showErrorMessage("No se pudo obtener la información del usuario");
        return;
      }
      
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .get();
      
      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _controllerNombre.text = userData['nombre'] ?? '';
          _controllerTelefono.text = userData['telefono'] ?? '';
          _controllerCarrera.text = userData['carrera'] ?? '';
          currentImageUrl = userData['imagen'];
          imageUrl = currentImageUrl;
          _isLoading = false;
        });
      } else {
        _showErrorMessage("No se encontraron datos del usuario");
      }
    } catch (e) {
      print("Error al cargar datos: $e");
      _showErrorMessage("Error al cargar datos del usuario");
    }
  }
  
  Future<void> _seleccionarImagen() async {
    try {
      final XFile? selectedImage = await getImage();
      if (selectedImage != null) {
        setState(() {
          _selectedImage = File(selectedImage.path);
        });
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
      _showErrorMessage("Error al seleccionar la imagen");
    }
  }
  
  Future<void> _eliminarImagenAnterior() async {
    if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      try {
        // Obtener referencia a la imagen anterior para eliminarla
        Reference storageRef = FirebaseStorage.instance.refFromURL(currentImageUrl!);
        await storageRef.delete();
        print("Imagen anterior eliminada con éxito");
      } catch (e) {
        print("Error al eliminar imagen anterior: $e");
        // Continuar con la actualización aunque falle la eliminación
      }
    }
  }
  
  void _updateImageUrl(String url) {
    setState(() {
      imageUrl = url;
    });
  }
  
  Future<void> _guardarCambios() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Si se seleccionó una nueva imagen
      if (_selectedImage != null) {
        // Eliminar imagen anterior
        await _eliminarImagenAnterior();
        
        // Subir nueva imagen
        imageUrl = await subirImagenPerfil(
          _selectedImage!, 
          _updateImageUrl, 
          _controllerNombre
        );
      }
      
      // Actualizar datos en Firestore
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .update({
        'nombre': _controllerNombre.text,
        'telefono': _controllerTelefono.text,
        'carrera': _controllerCarrera.text,
        'imagen': imageUrl,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      
      // Regresar a la pantalla anterior
      Navigator.pop(context);
    } catch (e) {
      print("Error al guardar cambios: $e");
      _showErrorMessage("Error al guardar los cambios");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Editar Perfil', style: TextStyle(color: Colors.black, fontSize: 24)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Imagen de perfil con botón de edición
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: const Color(0xFF4CAF50).withOpacity(0.3),
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!) as ImageProvider
                              : (imageUrl != null && imageUrl!.isNotEmpty
                                  ? NetworkImage(imageUrl!) as ImageProvider
                                  : const AssetImage('assets/default_profile.png')),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _seleccionarImagen,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.black, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Campo Nombre
                    TextField(
                      controller: _controllerNombre,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFB5E6B7),
                        hintText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Campo Teléfono
                    TextField(
                      controller: _controllerTelefono,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFB5E6B7),
                        hintText: 'Teléfono',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    // Campo Carrera
                    TextField(
                      controller: _controllerCarrera,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFB5E6B7),
                        hintText: 'Carrera',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 80),
                    // Botón Guardar Cambios
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  @override
  void dispose() {
    _controllerNombre.dispose();
    _controllerTelefono.dispose();
    _controllerCarrera.dispose();
    super.dispose();
  }
}