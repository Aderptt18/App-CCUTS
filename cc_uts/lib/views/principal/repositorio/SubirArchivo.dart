import 'package:cc_uts/controlador/pdf/SeleccionarPDF.dart';
import 'package:cc_uts/controlador/pdf/SubirPdfFirebase.dart';
import 'package:cc_uts/servicios/almacenamiento/almacenamientoUid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubirDocumento extends StatefulWidget {
  @override
  _SubirDocumentoScreenState createState() => _SubirDocumentoScreenState();
}

class _SubirDocumentoScreenState extends State<SubirDocumento> {
  final _formKey = GlobalKey<FormState>();
  PlatformFile? _selectedPDF;
  bool _isLoading = false;
  int _uploadsToday = 0;
  final int _maxUploadsPerDay = 3;
  bool _fechaSeleccionada = false;
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _resumenController = TextEditingController();
  final _palabrasClaveController = TextEditingController();
  final _institucionController = TextEditingController();
  DateTime _fechaDocumento = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUploadsCount();
  }

  Future<void> _loadUploadsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUploadDate = prefs.getString('lastUploadDate') ?? '';
    if (lastUploadDate == DateTime.now().toString().split(' ')[0]) {
      setState(() {
        _uploadsToday = prefs.getInt('uploadsToday') ?? 0;
      });
    } else {
      await prefs.setInt('uploadsToday', 0);
      setState(() {
        _uploadsToday = 0;
      });
    }
  }

  Future<void> _updateUploadsCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'lastUploadDate', DateTime.now().toString().split(' ')[0]);
    await prefs.setInt('uploadsToday', _uploadsToday + 1);
  }

  Future<void> _selectPDF() async {
    final result = await getPDF();
    if (result != null) {
      setState(() {
        _selectedPDF = result;
      });
    }
  }

  void _clearSelectedPDF() {
    setState(() {
      _selectedPDF = null;
    });
  }

  Future<void> _publicarDocumento() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPDF == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor seleccione un archivo PDF')),
      );
      return;
    }

    if (_uploadsToday >= _maxUploadsPerDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Has alcanzado el límite de subidas por hoy')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? uid = await AlmacenamientoUid.getUID();
      if (uid == null) throw Exception('Usuario no autenticado');

      final String url = await subirPDF(
        _selectedPDF!,
        (String url) {},
        _tituloController,
      );

      // Agregar documento a la colección Documentos
      DocumentReference documentoRef = await FirebaseFirestore.instance.collection('Documentos').add({
        'titulo': _tituloController.text,
        'autor': _autorController.text,
        'descripcion': _descripcionController.text,
        'resumen': _resumenController.text,
        'palabras': _palabrasClaveController.text,
        'institucion': _institucionController.text,
        'fechadocumento': _fechaDocumento,
        'pdf':
            '${DateTime.now().millisecondsSinceEpoch}_${_tituloController.text}.pdf',
        'urlPdf': url,
        'timestamp': FieldValue.serverTimestamp(),
        'uidUsuario': uid,
      });

      // Obtener el ID del documento creado
      String documentoId = documentoRef.id;

      // Actualizar el array misArchivos del usuario
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .update({
        'misArchivos': FieldValue.arrayUnion([documentoId]),
      });

      await _updateUploadsCount();
      setState(() => _uploadsToday++);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Documento publicado exitosamente')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _selectedPDF = null;
        _fechaDocumento = DateTime.now();
        _fechaSeleccionada = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar el documento: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }

    Navigator.pop(context);
  /*
    _tituloController.clear();
    _autorController.clear();
    _descripcionController.clear();
    _resumenController.clear();
    _palabrasClaveController.clear();
    _institucionController.clear();*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subir documento'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _tituloController,
                hintText: 'Título...',
                maxLength: 150,
              ),
              _buildTextField(
                controller: _autorController,
                hintText: 'Autor...',
                maxLength: 100,
              ),
              _buildTextField(
                controller: _descripcionController,
                hintText: 'Descripción breve..',
                maxLength: 300,
              ),
              _buildTextField(
                controller: _resumenController,
                hintText: 'Resumen...',
                maxLength: 3000,
                expandable: true,
              ),
              _buildTextField(
                controller: _palabrasClaveController,
                hintText: 'Palabras clave...',
                maxLength: 50,
              ),
              _buildTextField(
                controller: _institucionController,
                hintText: 'Institución...',
                maxLength: 200,
              ),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _fechaDocumento,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _fechaDocumento = picked;
                      _fechaSeleccionada =
                          true; // Marcamos que se seleccionó una fecha
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(
                    _fechaSeleccionada
                        ? '${_fechaDocumento.day.toString().padLeft(2, '0')}/${_fechaDocumento.month.toString().padLeft(2, '0')}/${_fechaDocumento.year}'
                        : 'Fecha del documento...',
                    style: TextStyle(
                      color:
                          _fechaSeleccionada ? Colors.black87 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    if (_selectedPDF != null)
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/archivo-pdf.png',
                              height: 40,
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _selectedPDF!.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedPDF != null)
                            Container(
                              width: 40,
                              height: 40,
                              margin: EdgeInsets.only(right: 5),
                              child: FloatingActionButton(
                                backgroundColor: Colors.red,
                                mini: true,
                                child: Icon(Icons.delete),
                                onPressed: _clearSelectedPDF,
                              ),
                            ),
                          Container(
                            width: 40,
                            height: 40,
                            child: FloatingActionButton(
                              backgroundColor: Colors.green,
                              mini: true,
                              child: Icon(Icons.add),
                              onPressed: _selectPDF,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _isLoading ? null : _publicarDocumento,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Publicar',
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                    SizedBox(width: 8),
                    Icon(Icons.send),
                    if (_isLoading)
                      Container(
                        width: 20,
                        height: 20,
                        margin: EdgeInsets.only(left: 10),
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Documentos restantes hoy: ${_maxUploadsPerDay - _uploadsToday}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int maxLength,
    bool expandable = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: expandable ? null : 1,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.green[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _descripcionController.dispose();
    _resumenController.dispose();
    _palabrasClaveController.dispose();
    _institucionController.dispose();
    super.dispose();
  }
}