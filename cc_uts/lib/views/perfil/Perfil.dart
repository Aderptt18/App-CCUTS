import 'dart:io';

import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:cc_uts/servicios/firebase/Autenticacion.dart';
import 'package:cc_uts/views/perfil/EditarPerfil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  Map<String, dynamic> userData = {};

 @override
 void initState() {
   super.initState();
   _cargarDatosUsuario();
 }

 Future<void> _cargarDatosUsuario() async {
   String? uid = await AlmacenamientoUid.getUID();
   if (uid != null) {
     DocumentSnapshot doc = await FirebaseFirestore.instance
         .collection('Usuarios')
         .doc(uid)
         .get();
     
     if (doc.exists) {
       setState(() {
         userData = doc.data() as Map<String, dynamic>;
       });
     }
   }
 }


  Widget _signOut() {
    return ElevatedButton(
      onPressed: () {
        Auth().signOut();
      },
      child: const Text('Cerrar Sesión'),
    );
  }
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text(''),
       backgroundColor: Colors.green,
       actions: [
         TextButton(
           onPressed: () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => EditarPerfil(),
               ),
             );
           },
           child: Text('Editar', style: TextStyle(color: Colors.black)),
         ),
       ],
     ),
     body: SingleChildScrollView(
       child: Padding(
         padding: EdgeInsets.all(20),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Center(
               child: CircleAvatar(
                 radius: 80,
                 backgroundImage: NetworkImage(userData['imagen'] ?? ''),
               ),
             ),
             SizedBox(height: 40),
             _buildInfoRow('Nombre:', userData['nombre'] ?? ''),
             _buildInfoRow('Correo', userData['correo'] ?? ''),
             _buildInfoRow('Telefono', userData['telefono'] ?? ''),
             _buildInfoRow('Dirección', userData['direccion'] ?? ''),
             _signOut(),
           ],
         ),
       ),
     ),
   );
 }

 Widget _buildInfoRow(String label, String value) {
   return Padding(
     padding: EdgeInsets.symmetric(vertical: 10),
     child: Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           label,
           style: TextStyle(
             fontSize: 24,
             fontWeight: FontWeight.bold,
           ),
         ),
         SizedBox(width: 20),
         Expanded(
           child: Text(
             value,
             style: TextStyle(fontSize: 24),
           ),
         ),
       ],
     ),
   );
 }
}



/*
class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de Usuarios'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Usuarios').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Ocurrió un error al cargar los datos.'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final usuarios = snapshot.data!.docs;

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(usuario['imagen']),
                ),
                title: Text(usuario['nombre']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Correo: ${usuario['correo']}'),
                    Text('Teléfono: ${usuario['telefono']}'),
                    Text('Dirección: ${usuario['direccion']}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


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
*/

