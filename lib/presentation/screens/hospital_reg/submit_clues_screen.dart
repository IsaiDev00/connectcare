import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SubmitCluesScreen extends StatefulWidget {
  const SubmitCluesScreen({super.key});

  @override
  _SubmitCluesScreen createState() => _SubmitCluesScreen();
}

class _SubmitCluesScreen extends State<SubmitCluesScreen>{
  PlatformFile? pickedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Clues'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Mensaje informativo
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: Center(
                  child: const Text(
                    'Por favor, adjunte un archivo PDF que contenga las pistas que desea enviar. Asegúrese de que el archivo sea legible y esté en el formato correcto.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Botón para seleccionar archivo
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Seleccionar PDF'),
            ),
            const SizedBox(height: 20),

            // Botón de submit
            ElevatedButton(
              onPressed: pickedFile != null
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Archivo enviado: ${pickedFile!.name}'),
                        ),
                      );
                    }
                  : null,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}