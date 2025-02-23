import 'dart:io'; // Importa la biblioteca de Dart para manejar archivos.
import 'package:firebase_storage/firebase_storage.dart'; // Importa la biblioteca de Firebase Storage para manejar el almacenamiento en Firebase.
import 'package:flutter/material.dart'; // Importa la biblioteca de Flutter para construir interfaces de usuario.

final FirebaseStorage storage = FirebaseStorage.instance; // Crea una instancia de FirebaseStorage para interactuar con el almacenamiento de Firebase.


//perfil
Future<String> subirImagenPerfil(File image, Function(String) updateUrl, TextEditingController controller) async {
  try {
    // Usar timestamp para evitar nombres duplicados
    final String nameFile = "${DateTime.now().millisecondsSinceEpoch}_${controller.text}";
    final Reference ref = storage.ref().child("Perfiles").child(nameFile);
    
    // Configurar metadata para la imagen
    final SettableMetadata metadata = SettableMetadata( 
      contentType: 'image/jpeg',  // Ajusta según el tipo de imagen
      customMetadata: {'picked-file-path': image.path}
    );

    // Subir el archivo con metadata
    final UploadTask uploadTask = ref.putFile(image, metadata);
    
    // Esperar a que se complete la subida
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);
    
    // Obtener la URL
    final String url = await snapshot.ref.getDownloadURL();
    
    updateUrl(url);
    return url;
  } catch (e) {
    print("Error detallado al subir imagen: $e");
    throw Exception('Error al subir la imagen: $e');
  }
}


//publicacion
Future<String> subirImagenPublicacion(File image, Function(String) updateUrl, TextEditingController controller) async {
  try {
    // Usar timestamp para evitar nombres duplicados
    final String nameFile = "${DateTime.now().millisecondsSinceEpoch}_${controller.text}";
    final Reference ref = storage.ref().child("Publicaciones").child(nameFile);
    
    // Configurar metadata para la imagen
    final SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg',  // Ajusta según el tipo de imagen
      customMetadata: {'picked-file-path': image.path}
    );

    // Subir el archivo con metadata
    final UploadTask uploadTask = ref.putFile(image, metadata);
    
    // Esperar a que se complete la subida
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);
    
    // Obtener la URL
    final String url = await snapshot.ref.getDownloadURL();
    
    updateUrl(url);
    return url;
  } catch (e) {
    print("Error detallado al subir imagen: $e");
    throw Exception('Error al subir la imagen: $e');
  }
}
          