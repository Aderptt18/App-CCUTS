import 'package:cc_uts/servicios/Autenticacion.dart';
import 'package:cc_uts/views/autentificacion/home_page.dart';
import 'package:cc_uts/views/autentificacion/login_register_page.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
       if (snapshot.hasData){
        return HomePage();
       }else{
        return LoginPage();
       }
      },
    );
  }
}