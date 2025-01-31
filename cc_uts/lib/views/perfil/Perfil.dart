import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:cc_uts/servicios/firebase/Autenticacion.dart';
import 'package:cc_uts/views/perfil/EditarPerfil.dart';
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
    return IconButton(
        icon: Icon(Icons.exit_to_app, color: Colors.red, size: 30),
        onPressed: () {
          Auth().signOut();
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.green,
        actions: [
          _signOut(),
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
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ['Nombre', 'Correo', 'Teléfono', 'Dirección']
                            .map((label) => Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: Text(label,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ))
                            .toList(),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ['nombre', 'correo', 'telefono', 'direccion']
                            .map((key) => Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(userData[key] ?? '',
                                      style: TextStyle(fontSize: 17)),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
