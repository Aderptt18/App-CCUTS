import 'dart:io'; // Para manejar archivos
import 'package:firebase_storage/firebase_storage.dart'; // Para Firebase Storage
import 'package:flutter/material.dart'; // Para Flutter
import 'package:file_picker/file_picker.dart';

final FirebaseStorage storage = FirebaseStorage.instance; // Instancia de Firebase Storage

// Función para subir un archivo PDF a Firebase Storage
Future<String> subirPDF(PlatformFile pdfFile, Function(String) updateUrl, TextEditingController controller) async {
  try {
    // Crear un nombre único para el archivo PDF usando un timestamp y el nombre del usuario
    final String nameFile = "${DateTime.now().millisecondsSinceEpoch}_${controller.text}.pdf";
    
    // Referencia al archivo en Firebase Storage (en la carpeta "PDFs")
    final Reference ref = storage.ref().child("PDFs").child(nameFile);

    // Configurar metadata para el archivo PDF
    final SettableMetadata metadata = SettableMetadata(
      contentType: 'application/pdf', // Tipo MIME para PDF
      customMetadata: {'picked-file-path': pdfFile.path ?? ''}, // Ruta del archivo
    );

    // Convertir PlatformFile a File
    final File file = File(pdfFile.path!);

    // Subir el archivo con metadata
    final UploadTask uploadTask = ref.putFile(file, metadata);

    // Esperar a que se complete la subida
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);

    // Obtener la URL de descarga
    final String url = await snapshot.ref.getDownloadURL();

    // Actualizar la URL (si se proporciona una función de callback)
    updateUrl(url);

    // Devolver la URL de descarga
    return url;
  } catch (e) {
    print("Error detallado al subir PDF: $e");
    throw Exception('Error al subir el PDF: $e');
  }
}