import 'package:image_picker/image_picker.dart';

// Definición de la función para obtener una imagen desde la galería
Future<XFile?> getImage() async {
  // Se crea una instancia de ImagePicker
  final ImagePicker picker = ImagePicker();
  // Se utiliza el método pickImage para seleccionar una imagen de la galería
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  // Se devuelve la imagen seleccionada (puede ser null si no se selecciona ninguna)
  return image;
}
