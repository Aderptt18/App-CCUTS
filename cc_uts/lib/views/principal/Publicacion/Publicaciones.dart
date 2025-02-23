import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class Publicaciones extends StatefulWidget {
  @override
  _PDFPickerScreenState createState() => _PDFPickerScreenState();
}

class _PDFPickerScreenState extends State<Publicaciones> {
  PlatformFile? pdfFile;

  Future<PlatformFile?> getPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      return result.files.first;
    } else {
      return null;
    }
  }

  void _pickPDF() async {
    final file = await getPDF();
    if (file != null) {
      setState(() {
        pdfFile = file;
      });
      print("PDF seleccionado: ${file.name}");
    } else {
      print("No se seleccionó ningún PDF");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar PDF"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pdfFile != null)
              Text(
                "PDF seleccionado: ${pdfFile!.name}",
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickPDF,
              child: Text("Seleccionar PDF"),
            ),
          ],
        ),
      ),
    );
  }
}