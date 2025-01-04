import 'package:cc_uts/controlador/Pantallas.dart';
import 'package:cc_uts/widgets/widget_tree.dart';
import 'package:cc_uts/views/autentificacion/Registro.dart';
import 'package:flutter/material.dart';

class Acceso extends StatelessWidget {
  const Acceso({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  const WidgetTree(),
    );
    
  }
}
