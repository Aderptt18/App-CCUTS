import 'package:cc_uts/controlador/Pantallas.dart';
import 'package:cc_uts/servicios/firebase/Autenticacion.dart';
import 'package:cc_uts/views/autentificacion/login_register_page.dart';
import 'package:flutter/material.dart';

class Acceso extends StatefulWidget {
  const Acceso({super.key});

  @override
  State<Acceso> createState() => _AccesoState();
}

class _AccesoState extends State<Acceso> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Pantallas();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
