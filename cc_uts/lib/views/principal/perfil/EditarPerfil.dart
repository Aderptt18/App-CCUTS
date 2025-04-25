import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:cc_uts/controlador/Imagenes/SeleccionarImagen.dart';
import 'package:cc_uts/controlador/Imagenes/SubirImagenFirebase.dart';
import 'package:cc_uts/servicios/firebase/Autenticacion.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({Key? key}) : super(key: key);

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final TextEditingController _controllerNombre = TextEditingController();
  final TextEditingController _controllerTelefono = TextEditingController();
  final TextEditingController _controllerCarrera = TextEditingController();
  
  // Controladores para cambio de contraseña
  final TextEditingController _controllerCurrentPassword = TextEditingController();
  final TextEditingController _controllerNewPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController();
  
  String? imageUrl;
  String? currentImageUrl;
  File? _selectedImage;
  bool _isLoading = true;
  String? userId;
  
  // Variables para controlar la sección de cambio de contraseña
  bool _showPasswordSection = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
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
    // Validación de teléfono (opcional, pero si se proporciona debe comenzar con 3 y tener 10 dígitos)
    if (_controllerTelefono.text.isNotEmpty && !RegExp(r'^3\d{9}$').hasMatch(_controllerTelefono.text)) {
      _showErrorMessage("Número de teléfono es inválido");
      setState(() => _isLoading = false);
      return;
    }
    
    // Validación de nombre (no vacío y mínimo 3 caracteres)
    if (_controllerNombre.text.trim().isEmpty || _controllerNombre.text.trim().length < 3) {
      _showErrorMessage("El nombre debe tener al menos 3 caracteres");
      setState(() => _isLoading = false);
      return;
    }
    
    // La carrera puede quedar vacía (no se valida)
    
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
      'nombre': _controllerNombre.text.trim(),
      'telefono': _controllerTelefono.text.trim(),
      'carrera': _controllerCarrera.text.trim(),
      'imagen': imageUrl,
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente'),
        backgroundColor: Colors.green,
      )
    );
    
    // Si hay datos de contraseña, intentar cambiar la contraseña
    if (_controllerCurrentPassword.text.isNotEmpty && 
        _controllerNewPassword.text.isNotEmpty &&
        _controllerConfirmPassword.text.isNotEmpty) {
      await _cambiarContrasena();
    }
    
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
  
  Future<void> _cambiarContrasena() async {
    // Verificar que las contraseñas coinciden
    if (_controllerNewPassword.text != _controllerConfirmPassword.text) {
      _showErrorMessage("Las contraseñas nuevas no coinciden");
      return;
    }
    
    // Verificar que la contraseña tenga al menos 6 caracteres
    if (_controllerNewPassword.text.length < 6) {
      _showErrorMessage("La contraseña debe tener al menos 6 caracteres");
      return;
    }
    
    try {
      await Auth().changePassword(
        currentPassword: _controllerCurrentPassword.text,
        newPassword: _controllerNewPassword.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );
      
      // Limpiar los campos de contraseña
      _controllerCurrentPassword.clear();
      _controllerNewPassword.clear();
      _controllerConfirmPassword.clear();
      
    } catch (e) {
      print("Error al cambiar contraseña: $e");
      
      // Mostrar mensaje de error más específico
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            _showErrorMessage("La contraseña actual es incorrecta");
            break;
          case 'weak-password':
            _showErrorMessage("La nueva contraseña es muy débil");
            break;
          case 'requires-recent-login':
            _showErrorMessage("Esta operación es sensible. Por favor, cierre sesión y vuelva a iniciar sesión para cambiar la contraseña");
            break;
          default:
            _showErrorMessage("Error al cambiar contraseña: ${e.message}");
        }
      } else {
        _showErrorMessage("Error al cambiar contraseña");
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
  
  Widget _buildPasswordFields() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showPasswordSection ? 240 : 0,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Contraseña actual
            TextField(
              controller: _controllerCurrentPassword,
              obscureText: _obscureCurrentPassword,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFB5E6B7),
                hintText: 'Contraseña actual',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Nueva contraseña
            TextField(
              controller: _controllerNewPassword,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFB5E6B7),
                hintText: 'Nueva contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Confirmar nueva contraseña
            TextField(
              controller: _controllerConfirmPassword,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFB5E6B7),
                hintText: 'Confirmar nueva contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                    const SizedBox(height: 20),
                    
                    // Botón para mostrar/ocultar sección de cambio de contraseña
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showPasswordSection = !_showPasswordSection;
                        });
                      },
                      icon: Icon(
                        _showPasswordSection ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFF4CAF50),
                      ),
                      label: Text(
                        _showPasswordSection ? 'Ocultar cambio de contraseña' : 'Cambiar contraseña',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                    
                    // Sección de cambio de contraseña (expandible)
                    _buildPasswordFields(),
                    
                    const SizedBox(height: 40),
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
    _controllerCurrentPassword.dispose();
    _controllerNewPassword.dispose();
    _controllerConfirmPassword.dispose();
    super.dispose();
  }
}