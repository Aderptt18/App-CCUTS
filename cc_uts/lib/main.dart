import 'package:cc_uts/app/app.dart';
import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AlmacenamientoUid.init();
  runApp(MyApp());
}

