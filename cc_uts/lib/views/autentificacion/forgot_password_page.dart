import 'package:flutter/material.dart';
import 'package:cc_uts/servicios/firebase/Autenticacion.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  String? errorMessage;
  bool isEmailSent = false;

  Future<void> _resetPassword() async {
    if (_controllerEmail.text.isEmpty) {
      _showErrorMessage("Por favor ingresa tu correo electrónico");
      return;
    }

    try {
      await Auth().sendPasswordResetEmail(
        email: _controllerEmail.text,
      );
      setState(() {
        isEmailSent = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
      _showErrorMessage(e.message ?? "Error al enviar el correo");
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _successMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 60,
        ),
        const SizedBox(height: 20),
        const Text(
          "¡Correo enviado!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
          ),
          child: const Text("Volver al inicio de sesión"),
        ),
      ],
    );
  }

  Widget _resetForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "¿Olvidaste tu contraseña?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          "Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _controllerEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
          ),
          child: const Text("Enviar correo"),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Volver al inicio de sesión"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: isEmailSent ? _successMessage() : _resetForm(),
        ),
      ),
    );
  }
}