import 'dart:io';
import 'package:cc_uts/controlador/Imagenes/SeleccionarImagen.dart';
import 'package:cc_uts/controlador/Imagenes/SubirImagenFirebase.dart';
import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:cc_uts/servicios/firebase/Autenticacion.dart';
import 'package:cc_uts/views/autentificacion/forgot_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMesage = '';
  bool confirmarContrasena = true;
  bool isLogin = true;
  bool _isLoading = false;

  // Control de imagen de perfil
  String urlImagen = '';
  File? obtenerImagen;

   // Control de visibilidad de contraseña
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // Firebase
  final firebase = FirebaseFirestore.instance;

  // Controladores
  final TextEditingController _controllerNombre = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();
  final TextEditingController _controllerCarrera = TextEditingController();
  final TextEditingController _controllerTelefono = TextEditingController();

  // Ingresar
  Future<void> signInWithEmailAndPassword() async {
    setState(() => _isLoading = true);
    
    try {
      final UserCredential userCredential =
          await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      // Guardar el UID del usuario en el almacenamiento local
      await AlmacenamientoUid.saveUID(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMesage = e.message;
      });
      _showErrorMessage("Correo o contraseña incorrectos");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Crear cuenta
  Future<void> createUserWithEmailAndPassword() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    // Validaciones
    if (_controllerPassword.text.length < 6) {
      _showErrorMessage("La contraseña debe tener al menos 6 caracteres");
      setState(() => _isLoading = false);
      return;
    }

    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      if (mounted) {
        setState(() {
          confirmarContrasena = false;
          _isLoading = false;
        });
      }
      return;
    }

    if (!RegExp(r'^3\d{9}$').hasMatch(_controllerTelefono.text)) {
      _showErrorMessage("El teléfono es inválido");
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Crear el usuario en Firebase Auth
      final UserCredential userCredential =
          await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      // 2. Subir la imagen si existe y obtener la URL
      String imageUrl = '';
      if (obtenerImagen != null && mounted) {
        try {
          imageUrl = await subirImagenPerfil(
            obtenerImagen!,
            (String urlI) {
              if (mounted) {
                setState(() {
                  urlImagen = urlI;
                });
              }
            },
            _controllerNombre,
          );
        } catch (e) {
          print("Error al subir imagen: $e");
          if (mounted) {
            _showErrorMessage("Error al subir la imagen");
            setState(() => _isLoading = false);
          }
          return;
        }
      }

      // 3. Crear el documento en Firestore
      if (userCredential.user != null) {
        try {
          await firebase
              .collection('Usuarios')
              .doc(userCredential.user!.uid)
              .set({
            'nombre': _controllerNombre.text,
            'correo': _controllerEmail.text,
            'telefono': _controllerTelefono.text,
            'carrera': _controllerCarrera.text,
            'imagen': imageUrl,
            'uid': userCredential.user!.uid,
            'publicaciones': [],
            'misArchivos': []
          });

          await AlmacenamientoUid.saveUID(userCredential.user!.uid);

          print("Usuario creado con éxito");
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cuenta creada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          print("Error al crear documento en Firestore: $e");
          if (mounted) {
            _showErrorMessage("Error al guardar los datos del usuario");
          }
          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      print("Error de autenticación: ${e.message}");
      if (mounted) {
        setState(() {
          errorMesage = e.message;
        });
        _showErrorMessage(e.message ?? "Error al crear la cuenta");
      }
    } catch (e) {
      print("Error inesperado: $e");
      if (mounted) {
        _showErrorMessage("Error inesperado al crear la cuenta");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _imagenLogo() {
    return ClipOval(
      child: Image.asset(
        'assets/Logo.png',
        height: 150,
        width: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> _seleccionarImagen() async {
    try {
      final imagen = await getImage();
      if (imagen != null) {
        setState(() {
          obtenerImagen = File(imagen.path);
        });
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
      _showErrorMessage("Error al seleccionar la imagen");
    }
  }

  Widget _espacio(double size) {
    return SizedBox(
      height: size,
    );
  }

  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false, bool confirmPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword 
          ? (confirmPassword ? !_confirmPasswordVisible : !_passwordVisible)
          : false,
      keyboardType: title == 'Teléfono' ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: title,
        filled: true,
        fillColor: Color(0xFFB8E6B9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(
                confirmPassword 
                  ? (_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off)
                  : (_passwordVisible ? Icons.visibility : Icons.visibility_off),
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  if (confirmPassword) {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  } else {
                    _passwordVisible = !_passwordVisible;
                  }
                });
              },
            )
          : null,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading 
          ? null 
          : (isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4CAF50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      icon: _isLoading 
          ? Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(2.0),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : Icon(isLogin ? Icons.login : Icons.person_add, color: Colors.black),
      label: Text(
        isLogin ? 'INGRESAR' : 'CREAR CUENTA',
        style: TextStyle(color: Colors.black),
      ),
    );
  }
Widget _buildProfileImageSelector() {
  return Stack(
    alignment: Alignment.center,
    children: [
      // Avatar/Imagen
      CircleAvatar(
        radius: 75,
        backgroundColor: Color(0xFFB8E6B9),
        backgroundImage: obtenerImagen != null
            ? FileImage(obtenerImagen!) as ImageProvider
            : AssetImage('assets/Logo.png'),
        // Removed the person icon that was appearing on top of the logo
      ),
      // Botón de edición en la esquina inferior derecha
      Positioned(
        bottom: 0,
        right: 0,
        child: GestureDetector(
          onTap: _seleccionarImagen,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          // Reiniciar estado de errores al cambiar de modo
          confirmarContrasena = true;
        });
      },
      child: Text(
        isLogin ? '¿No tienes cuenta? Crea la tuya' : '¿Ya tienes cuenta? Ingresar',
        style: TextStyle(color: Color(0xFF4CAF50)),
      ),
    );
  }

  Widget _errorContrasena() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        'Las contraseñas no coinciden',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _forgotPasswordButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
        );
      },
      child: const Text(
        "¿Olvidaste tu contraseña?",
        style: TextStyle(color: Color(0xFF4CAF50)),
      ),
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFF4CAF50),
      elevation: 0,
      title: Text(isLogin ? 'Iniciar Sesión' : 'Crear Cuenta'),
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _espacio(20),
                    if (isLogin) ...[
                      _espacio(30),
                      Center(child: _imagenLogo()),
                      _espacio(120),
                      _entryField('Correo electrónico', _controllerEmail),
                      _espacio(16),
                      _entryField('Contraseña', _controllerPassword, isPassword: true),
                      _espacio(40),
                    ] else ...[
                      Center(
                        child: _buildProfileImageSelector(),
                      ),
                      _espacio(30),
                      _entryField('Nombre', _controllerNombre),
                      _espacio(16),
                      _entryField('Correo electrónico', _controllerEmail),
                      _espacio(16),
                      _entryField('Contraseña', _controllerPassword, isPassword: true),
                      _espacio(16),
                      _entryField('Confirmar contraseña', _controllerConfirmPassword, isPassword: true, confirmPassword: true),
                      if (!confirmarContrasena) ...[
                        _errorContrasena(),
                      ],
                      _espacio(16),
                      _entryField('Carrera', _controllerCarrera),
                      _espacio(16),
                      _entryField('Teléfono', _controllerTelefono),
                      _espacio(20),
                    ],
                    _submitButton(),
                    _espacio(16),
                    if (isLogin) ...[
                      _forgotPasswordButton(),
                    ],
                    _loginOrRegisterButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
}