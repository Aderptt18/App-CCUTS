import 'package:file_picker/file_picker.dart';

// Función para seleccionar un archivo PDF
Future<PlatformFile?> getPDF() async {
  // Abre el selector de archivos
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'], // Solo permite archivos PDF
  );

  // Si el usuario selecciona un archivo, devuelve el primero
  if (result != null) {
    return result.files.first;
  } else {
    // Si no se selecciona ningún archivo, devuelve null
    return null;
  }
}