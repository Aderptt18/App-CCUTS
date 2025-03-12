import 'package:flutter/material.dart';



class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({Key? key}) : super(key: key);

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  // Controladores para los campos de texto
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final carreraController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    carreraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Widget de foto de perfil
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green,
                        width: 4,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://via.placeholder.com/150', // Reemplazar con la URL real de la imagen
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Campos de entrada
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  hintText: 'Nombre',
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(
                  hintText: 'Telefono',
                  contentPadding: EdgeInsets.all(20),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: carreraController,
                decoration: const InputDecoration(
                  hintText: 'Carrera',
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 240), // Espacio adicional antes del botón
              // Botón de guardar cambios
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Implementar la funcionalidad para guardar cambios
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Guardar cambios',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}