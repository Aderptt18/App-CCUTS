import 'dart:io';
import 'package:cc_uts/controlador/Imagenes/SeleccionarImagen.dart';
import 'package:cc_uts/controlador/Imagenes/SubirImagenFirebase.dart';
import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:cc_uts/servicios/firebase/Autenticacion.dart';
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

  //control imagenes
  String urlImagen = '';
  File? obtenerImagen;

  //firebase
  final firebase = FirebaseFirestore.instance;
  //final User? user = Auth().currentUser;

  //controladores
  final TextEditingController _controllerNombre = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();
  final TextEditingController _controllerCarrera = TextEditingController();
  final TextEditingController _controllerTelefono = TextEditingController();

  //ingresar
  Future<void> signInWithEmailAndPassword() async {
    try {
      final UserCredential userCredential =
          await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      // Guardar el UID del usuario en el almacenamiento local
      await AlmacenamientoUid.saveUID(userCredential.user!.uid);

      // Aquí puedes hacer algo con userCredential si lo necesitas

      
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMesage = e.message;
      });
      _showErrorMessage("Correo o contraseña incorrectos");
    }
  }

  //crear cuenta
  Future<void> createUserWithEmailAndPassword() async {
    if (!mounted) return; // Verificar si el widget está montado

    if (_controllerPassword.text.length < 6) {
      _showErrorMessage("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      if (mounted) {
        // Verificar antes de llamar setState
        setState(() {
          confirmarContrasena = false;
        });
      }
      return;
    }

    if (!RegExp(r'^3\d{9}$').hasMatch(_controllerTelefono.text)) {
      _showErrorMessage(
          "El teléfono es inválido");
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
                // Verificar antes de actualizar el estado
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
            'chats': [],
            'publicaciones': [],
            'misArchivos': []
          });

          await AlmacenamientoUid.saveUID(userCredential.user!.uid); //almacena el uid del usuario


          print("Usuario creado con éxito");
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
        // Verificar antes de actualizar el estado
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
    }
  }

  Widget _title() {
    return const Text('');
  }

  Widget _imagenLogo() {
    return ClipOval(
      child: Image.asset(
        'assets/Logo.png', // Ruta al logo en assets
        height: 150, // Altura del logo
        width: 150, // Ancho del logo para mantener la proporción
        fit: BoxFit.cover, // Ajustar la imagen para cubrir el contenedor
      ),
    );
  }

  Widget _imagenSeleccionada() {
    return ClipOval(
      child: Image.file(
        obtenerImagen!,
        height: 150,
        width: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _espacio(double size) {
    return SizedBox(
      height: size,
    );
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
        controller: controller,
        obscureText: title == 'Contraseña' ||
            title ==
                'Confirmar contraseña', // Ocultar texto si es contraseña o confirmar contraseña
        decoration: InputDecoration(
          labelText: title,
          border: UnderlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
        ));
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  //boton para ingresar o crear cuenta
  Widget _submitButton() {
    return ElevatedButton(
        onPressed: isLogin
            ? signInWithEmailAndPassword
            : createUserWithEmailAndPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        ),
        child: Text(isLogin ? 'Ingresar' : 'Crear cuenta'));
  }

  //botón para subir imagen
  Widget _subirImagen() {
    return IconButton(
      icon: Icon(Icons.upload),
      onPressed: () async {
        final imagen = await getImage();
        setState(() {
          obtenerImagen = File(imagen!.path);
        });
      },
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text(
            isLogin ? '¿No tienes cuenta?, crea la tuya' : '¿Tienes cuenta?'));
  }

  Widget _errorContrasena() {
    return Text('Las contraseñas no coinciden');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        //permite que la pantalla sea scrollable
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _espacio(50),
                      if (isLogin) ...[
                        _imagenLogo(),
                        _espacio(120),
                        _entryField('Correo electrónico', _controllerEmail),
                        _entryField('Contraseña', _controllerPassword),
                        _espacio(20),
                      ] else ...[
                        obtenerImagen == null
                            ? _imagenLogo()
                            : _imagenSeleccionada(),
                        _subirImagen(),
                        _espacio(50),
                        _entryField('Nombre', _controllerNombre),
                        _entryField('Correo electrónico', _controllerEmail),
                        _entryField('Contraseña', _controllerPassword),
                        _entryField(
                            'Confirmar contraseña', _controllerConfirmPassword),
                        if (!confirmarContrasena) ...[
                          _espacio(10),
                          _errorContrasena(),
                        ] else
                          ...[], //este no hace nada
                        _entryField('Carrera', _controllerCarrera),
                        _entryField('Teléfono', _controllerTelefono),
                        _espacio(40),
                      ],
                      _submitButton(),
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

