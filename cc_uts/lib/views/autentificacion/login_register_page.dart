import 'package:cc_uts/servicios/Autenticacion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMesage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMesage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMesage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('');
  }

  Widget _imagen() {
    return ClipOval(
      child: Image.asset(
        'assets/Logo.png', // Ruta al logo en assets
        height: 120, // Altura del logo
        width: 120, // Ancho del logo para mantener la proporción
        fit: BoxFit.cover, // Ajustar la imagen para cubrir el contenedor
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
        obscureText: title == 'Contraseña', // Ocultar texto si es contraseña
        decoration: InputDecoration(
          labelText: title,
          border: UnderlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
        ));
  }

  Widget _errorMessage() {
    return Text(errorMesage == '' ? '' : 'Humm ? $errorMesage');
  }

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
        child: Text(isLogin ? 'Login' : 'Register'));
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text(isLogin ? 'Regístrate' : 'Inicir sesión'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imagen(),
            _espacio(150),
            _entryField('Correo electrónico', _controllerEmail),
            _entryField('Contraseña', _controllerPassword),
            _espacio(50),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}
