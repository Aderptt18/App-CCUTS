import 'dart:io';

import 'package:cc_uts/servicios/firebase/Autenticacion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Perfil extends StatelessWidget {
  Perfil({super.key});

  //variables
  String url = '';
  File? imagen_a_subir;
  final firebase = FirebaseFirestore.instance;
  final User? user = Auth().currentUser;

  //Controladores de texto
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final direccionController = TextEditingController();
  

  //metodos
  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text(' ');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _singOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  perfilUsuario() async{
    try {
      await firebase.collection('usuarios').doc().set({
        'nombre': nombreController.text,
        'correo': correoController.text,
        'telefono': telefonoController.text,
        'direccion': direccionController.text,
        'imagen': url,
        'uid': user?.uid,
      });
    }catch (e) {
      print("error.. " + e.toString());
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_outline,
                      size: 60,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Edit Profile Button
                ElevatedButton.icon(
                  onPressed: () {
                    // Implementar edición de perfil
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    'Editar Perfil',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            color: Colors.green,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Mis Publicaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Publications List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: 3, // Número de publicaciones de ejemplo
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.green[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Titulo:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Fecha: 01-01-2020'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _singOutButton()
        ],
      ),
    );
  }
}