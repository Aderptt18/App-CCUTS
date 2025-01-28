import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class AlmacenamientoUid {
  static const String _userBoxName = 'userBox';
  static const String _uidKey = 'uid';

  /// Inicializa Hive. Llama a este método en el inicio de la app.
  static Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
    } catch (e) {
      print('Error al inicializar Hive: $e');
      rethrow;
    }
  }

  /// Guarda el UID del usuario.
  static Future<void> saveUID(String uid) async {
    try {
      final box = await Hive.openBox(_userBoxName);
      await box.put(_uidKey, uid);
    } catch (e) {
      print('Error al guardar UID: $e');
      rethrow;
    }
  }

  /// Obtiene el UID guardado. Retorna `null` si no existe.
  static Future<String?> getUID() async {
    try {
      final box = await Hive.openBox(_userBoxName);
      return box.get(_uidKey);
    } catch (e) {
      print('Error al obtener UID: $e');
      return null;
    }
  }

  /// Elimina el UID guardado. Útil para logout.
  static Future<void> removeUID() async {
    try {
      final box = await Hive.openBox(_userBoxName);
      await box.delete(_uidKey);
    } catch (e) {
      print('Error al eliminar UID: $e');
      rethrow;
    }
  }

  /// Cierra todas las cajas abiertas. Útil para liberar recursos.
  static Future<void> closeBoxes() async {
    try {
      await Hive.close();
    } catch (e) {
      print('Error al cerrar cajas Hive: $e');
      rethrow;
    }
  }
}