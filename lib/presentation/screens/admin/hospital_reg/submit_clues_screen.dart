import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/main.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:core';
import 'dart:io' show File;

class SubmitCluesScreen extends StatefulWidget {
  const SubmitCluesScreen({super.key});

  @override
  SubmitCluesScreenState createState() => SubmitCluesScreenState();
}

class SubmitCluesScreenState extends State<SubmitCluesScreen> {
  PlatformFile? pickedFile;
  String? detectedText;
  img.Image? croppedImage;
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  bool isLoading = false;

  void _startLoadingAndAnalyze() {
    setState(() {
      isLoading = true; // Inicia el indicador de carga
    });

    Future.delayed(Duration(milliseconds: 100),
        _analyzeFile); // Llama a la función después de una breve pausa
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png']);
      if (result != null) {
        setState(() {
          pickedFile = result.files.first;
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar el archivo: $e");
      _fileErrorResponse(e);
    }
  }

  Future<void> _analyzeFile() async {
    if (pickedFile == null) return;

    setState(() {
      isLoading = true; // Mostrar indicador de carga
    });

    try {
      Uint8List fileBytes;

      if (pickedFile!.bytes != null) {
        fileBytes = pickedFile!.bytes!;
      } else if (pickedFile!.path != null) {
        final file = File(pickedFile!.path!);
        fileBytes = await file.readAsBytes();
      } else {
        throw Exception("No se pudo obtener los datos del archivo.");
      }

      img.Image? originalImage = img.decodeImage(fileBytes);
      if (originalImage == null) {
        throw Exception("No se pudo decodificar la imagen seleccionada.");
      }

      int cropWidth = (originalImage.width * 0.8).toInt();
      int cropHeight = (originalImage.height * 0.3).toInt();
      int cropX = (originalImage.width * 0.1).toInt();
      int cropY = (originalImage.height * 0.35).toInt();

      croppedImage = img.copyCrop(originalImage,
          x: cropX, y: cropY, width: cropWidth, height: cropHeight);

      final croppedBytes = img.encodeJpg(croppedImage!);
      final base64Image = base64Encode(croppedBytes);

      final accountCredentials = ServiceAccountCredentials.fromJson(r'''
    {
      "type": "service_account",
      "project_id": "connectcare-438217",
      "private_key_id": "6b5415f4de100b7b9255c5cf497eafb5ba580775",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDrU6FFpTDHQF1b\n1Comxf9Iy1C3Fjb+6W+zp6KUih5ghr/+O02liu2Ujah5XTON3wNLuHCB+hGAMPq1\n+q3MZoCZlsYGXny41rAwv5+gB9h07KzKSXMQiZ7Ly/3HwTyXBKvGY3GrSgeT0lA/\nS9iHITA+Cpb2LEW6IzdXFO65X1P28kjzNBQ+iXa8fwrT5aEpChaLt/U/J444X7fY\nJEDDovtv0I0qd5esGaNaSMyhsKddDblFfg2F5T5tSkergzHkWR1wOMJiLbqJKxxF\nGGhU9XeBWfC+KJZD10SX2yn5DxRd4xXB26t0BqaHw3mAha5FviamnhcGcqr4hw0N\ns4hx5j/VAgMBAAECggEAE6FvU5r7HbP91bo2JfPgXtcvDYbZ4ZvhiJAUXOXEsPKs\ns22JBaU4OmsywaUHtu8CnF9vazhMG3B6iZG2y9VFJwrPzBo3t0eZfQePLk9ZPC++\nHkXQRnHkgEWtDuvMvSBToAINqmdLiIZD0XPnRSZ8msBRZYm961Aivq3tWCNeorvc\nZPnB9AU/neKQ/PVOStRsAOEFEsKwQpLQUYoYizFiuwiLiJH95yq2IFw6I8BNdf0c\niDu1uhbubmZbXM/l/9Z1yRBfKLy6mFJ549b4NrksszaaXgXOQYWKjsHssUZxBlzR\nAalyB/B1nJGh+ZcpkovkYmKIxOBEzJV7pSweXfTB5QKBgQD/HWDwkMJf7F5PondY\nTlXfTDJOHOPs2bc275K/6XOqyPig0gUaDQ4NBdVdoquvmuBdhWSLr6zgFo3o2Mku\nKmlMbuXCZcQoIi2mCkuLfyK6wheKgslGqAgwd0MrUO1YIQqnHJzd/uDfhhB6/8tc\nCa1QPST1ARrTTS53GTsPM44KTwKBgQDsJKxe1LpSjqfszfUuBDSfJFCZzHFI/v0H\nwIMrqVkidhWRK0gvLfo/aq1JoTSUkQeLi0Si29r45bTvpjqzzlTirlcoNGwJwqxB\nQRThEGKFeUlZa0SDYiDVdaedG6VxpwIjI4/TnuTNp5f/JeDODqtSNUP6SvjkyaEn\n7dUSLNNemwKBgC4T41dv/fuPWLVvdbjYZUAwpgFfzHcSF7pvaQUKqF6Xb/i0FkHP\nS9NkU1ZXNEVCZvXdSvzD3SiYSkddKHETLfOlMBB9iwFosvADegOXEfHDbrcQykPd\nw6TlVZd0RXoedasbSuX5zCnzL/TXUKauBMSyVoN+EJdLoHHYd8dWG3iXAoGBAOtN\nv9Te9Kq/K+VzdRRdbHIHpakbZubt7wSCeDJRlVgZgnQdRNh+YBZBHlt4HwTLX1FV\nfRcrLI9HlXwXj/cLatpWDtMpKV6wdSSwzTVXNlT5/nTzxlmEtmL90f9jRQBzAlYx\nYWfltOiYT4UXIWMyitRn70zA2DJiGAvJmb96m0RxAoGAB+9LihWRXj2OwbtwrNhC\n0Xy5c0I1ZSGKItciKEjwEuwaeckgJOu5Bn7ug6lZc4Q81nVFeuQFgT62c/vNwY4S\nDzLq1x0LAOeLxnqAE600PjrVEMsz8BEjlaT7IiD2JNRAYQN1XHY/PWC+Q+c7y2WJ\nWrJZRSSiVesuYLfpSCmca1g=\n-----END PRIVATE KEY-----\n",
    "client_email": "connectcare-893@connectcare-438217.iam.gserviceaccount.com",
    "client_id": "115209440935153739424",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/connectcare-893%40connectcare-438217.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
    }
    ''');

      final scopes = [vision.VisionApi.cloudPlatformScope];
      final httpClient =
          await clientViaServiceAccount(accountCredentials, scopes);
      final visionApi = vision.VisionApi(httpClient);

      final request = vision.BatchAnnotateImagesRequest(requests: [
        vision.AnnotateImageRequest(
          image: vision.Image(content: base64Image),
          features: [vision.Feature(type: "DOCUMENT_TEXT_DETECTION")],
        )
      ]);

      final response = await visionApi.images.annotate(request);

      if (response.responses != null && response.responses!.isNotEmpty) {
        final fullText = response.responses!.first.fullTextAnnotation?.text ??
            "No se detectó texto.";
        final cluesPattern = RegExp(r'[A-Z]{5}\d{5,6}');
        final cluesMatch = cluesPattern.firstMatch(fullText);
        setState(() {
          detectedText = cluesMatch != null
              ? cluesMatch.group(0)
              : "No se detectó código CLUES.";
        });
        debugPrint("Texto detectado: $detectedText");

        _cluesResponse(detectedText);
      } else {
        debugPrint("No se recibió una respuesta válida de la API.");
        _invalidApiResponse();
        MyApp.nav.navigateTo('/cluesErrScreen');
      }
    } catch (e) {
      debugPrint("Error al analizar el archivo: $e");
      _errorParsingFile(e);
    } finally {
      setState(() {
        isLoading = false; // Ocultar indicador de carga
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
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: Center(
                  child: const Text(
                    'Ahora debe subir la imagen del certificado CLUES, es importante que sea legible y nítida.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickFile,
              child: Image.asset(
                'assets/images/agregar_documento.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickedFile != null ? _startLoadingAndAnalyze : null,
              child: const Text('Enviar'),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            if (detectedText != null) ...[
              const SizedBox(height: 20),
              Text(
                'Texto detectado:',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                detectedText!,
                style: const TextStyle(fontSize: 8),
              ),
            ],
            if (croppedImage != null) ...[
              const SizedBox(height: 20),
              Text(
                'Imagen recortada:',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Image.memory(
                Uint8List.fromList(img.encodeJpg(croppedImage!)),
                width: 200,
                height: 100,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _fileErrorResponse(e) {
    showCustomSnackBar(context, "Error al seleccionar el archivo: $e");
  }

  void _cluesResponse(detectedText) {
    showCustomSnackBar(context, "Texto detectado: $detectedText");

    if (detectedText != null && detectedText != "No se detectó código CLUES.") {
      _sharedPreferencesService.saveClues(detectedText!);
      showCustomSnackBar(context, "CLUES GUARDADO: $detectedText");
      Navigator.pushNamed(context, '/verificationCodeScreen');
    } else {
      Navigator.pushNamed(context, '/cluesErrScreen');
    }
  }

  void _invalidApiResponse() {
    showCustomSnackBar(
        context, "No se recibió una respuesta válida de la API.");
  }

  void _errorParsingFile(e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error al analizar el archivo: $e"),
      ),
    );
  }
}
