import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart'
    as http; // <-- Importante para enviar peticiones HTTP
import 'dart:core';

class SubmitCluesScreen extends StatefulWidget {
  const SubmitCluesScreen({super.key});

  @override
  SubmitCluesScreenState createState() => SubmitCluesScreenState();
}

class SubmitCluesScreenState extends State<SubmitCluesScreen> {
  PlatformFile? pickedFile;
  String? detectedText; // CLUES detectado
  img.Image? croppedImage;
  bool isLoading = false;

  // Servicio para get/set de SharedPreferences
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  /// Método para pedir permiso de almacenamiento de forma dinámica
  /// - Si Android 13+ => Permission.photos
  /// - Si Android <= 12 => Permission.storage
  Future<bool> _verificarPermisosAlmacenamiento() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      final statusPhotos = await Permission.photos.status;
      if (statusPhotos.isGranted) {
        return true;
      }
      if (statusPhotos.isDenied) {
        final newStatus = await Permission.photos.request();
        if (newStatus.isGranted) {
          return true;
        } else if (newStatus.isPermanentlyDenied) {
          showCustomSnackBar(
            context,
            "Los permisos para leer imágenes están permanentemente denegados. Habilítelos desde la configuración.",
          );
          openAppSettings();
          return false;
        } else {
          showCustomSnackBar(context, "Permiso para leer imágenes denegado.".tr());
          return false;
        }
      }
      if (statusPhotos.isPermanentlyDenied) {
        showCustomSnackBar(
          context,
          "Los permisos para leer imágenes están permanentemente denegados. Habilítelos desde la configuración.",
        );
        openAppSettings();
        return false;
      }
      return false;
    } else {
      final statusStorage = await Permission.storage.status;
      if (statusStorage.isGranted) {
        return true;
      }
      if (statusStorage.isDenied) {
        final newStatus = await Permission.storage.request();
        if (newStatus.isGranted) {
          return true;
        } else if (newStatus.isPermanentlyDenied) {
          showCustomSnackBar(
            context,
            "Los permisos de almacenamiento están permanentemente denegados. Habilítelos desde la configuración.",
          );
          openAppSettings();
          return false;
        } else {
          showCustomSnackBar(context, "Permiso de almacenamiento denegado.".tr());
          return false;
        }
      }
      if (statusStorage.isPermanentlyDenied) {
        showCustomSnackBar(
          context,
          "Los permisos de almacenamiento están permanentemente denegados. Habilítelos desde la configuración.",
        );
        openAppSettings();
        return false;
      }
      return false;
    }
  }

  /// Función para subir la imagen original a Cloudinary
  /// Retorna la secureUrl o null si falla
  Future<String?> _uploadImageToCloudinary(Uint8List imageBytes) async {
    print('Iniciando subida de imagen a Cloudinary...');

    const String cloudName = 'db4rwgxge';
    const String uploadPreset = 'Clues_image';

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url);

    request.fields['upload_preset'] = uploadPreset;
    final fileName = 'clues_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: fileName,
    ));

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(respStr);
        final secureUrl = jsonData['secure_url'];
        print('Imagen subida con éxito a Cloudinary: $secureUrl');
        return secureUrl;
      } else {
        print('Error al subir la imagen a Cloudinary: ${response.statusCode}');
        print('Respuesta de Cloudinary: $respStr');
        return null;
      }
    } catch (e) {
      print('Excepción al subir la imagen: $e');
      return null;
    }
  }

  Future<void> _registrarSolicitudHospital(
      String? clues, String? secureUrl) async {
    if (clues == null || secureUrl == null) {
      print(
          'Faltan datos para registrar la solicitud (clues o secureUrl nulos).');
      return;
    }

    // Obtenemos el id_usuario desde SharedPreferences
    final idUsuario = await _sharedPreferencesService.getUserId();
    if (idUsuario == null) {
      print('No se encontró id_usuario en SharedPreferences.');
      return;
    }

    final url = Uri.parse('$baseUrl/hospital/solicitudHospital');
    final body = {
      "clues": clues,
      "link_imagen": secureUrl,
      "id_usuario": idUsuario,
    };

    try {
      print('Enviando POST a $url con body: $body');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print(
          'Respuesta del servidor: ${response.statusCode} - ${response.body}');

      // Intentamos decodificar la respuesta como JSON
      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print('La respuesta no es un JSON válido: $e');
        responseData = null;
      }

      // Verificamos si la respuesta indica "status": 0
      if (responseData != null &&
          responseData is Map &&
          responseData['status'] == 0) {
        // Mostramos mensaje de error en rojo y salimos de la función
        showCustomSnackBar(context, "Invalid document", isError: true);
        return;
      }

      if (response.statusCode == 201) {
        showCustomSnackBar(context, "Solicitud registrada con éxito".tr());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DynamicWrapper(),
          ),
        );
      } else {
        showCustomSnackBar(
            context, "Error al registrar la solicitud: ${response.body}".tr());
      }
    } catch (e) {
      print('Excepción al hacer POST: $e');
      showCustomSnackBar(context, "Ocurrió un error al registrar la solicitud".tr());
    }
  }

  /// Inicia la detección y subida de imagen
  void _startLoadingAndAnalyze() async {
    bool permisoConcedido = await _verificarPermisosAlmacenamiento();
    if (!permisoConcedido) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 100), _analyzeFile);
  }

  /// Seleccionar la imagen
  Future<void> _pickFile() async {
    try {
      bool permisoConcedido = await _verificarPermisosAlmacenamiento();
      if (!permisoConcedido) {
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

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

  /// Analiza la imagen con Cloud Vision y sube la original a Cloudinary
  Future<void> _analyzeFile() async {
    if (pickedFile == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      Uint8List fileBytesOriginal;
      if (pickedFile!.bytes != null) {
        fileBytesOriginal = pickedFile!.bytes!;
      } else if (pickedFile!.path != null) {
        final file = File(pickedFile!.path!);
        fileBytesOriginal = await file.readAsBytes();
      } else {
        throw Exception("No se pudo obtener los datos del archivo.");
      }

      // Decodificamos la imagen
      final originalImage = img.decodeImage(fileBytesOriginal);
      if (originalImage == null) {
        throw Exception("No se pudo decodificar la imagen seleccionada.");
      }

      // Recorte (si lo necesitas)
      final cropWidth = (originalImage.width * 0.8).toInt();
      final cropHeight = (originalImage.height * 0.3).toInt();
      final cropX = (originalImage.width * 0.1).toInt();
      final cropY = (originalImage.height * 0.35).toInt();

      croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // Convertimos la imagen recortada a base64
      final croppedBytes = img.encodeJpg(croppedImage!);
      final base64Image = base64Encode(croppedBytes);

      // Autenticación con Vision
      final accountCredentials = ServiceAccountCredentials.fromJson(r'''
{
  "type": "service_account",
  "project_id": "connectcare-445200",
  "private_key_id": "28e7fde9b62e37213c3e57a5cc115857e8160164",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDcSZ4Ovic7JK3F\nIM05ak696umYcj0tWikuviHlLbquLNkw6ggnxGjzNjoLvEaroxk77EQMMRtT88rV\npmPyL1njS47MfanOM/qbAz892o1IlLnKIZbnJJV8zmLvUzDhJrSqJABxp4o3i4Ta\n8H9pVb91CuaC5x0JRRWffCVwOfZf8ndqQZC/FAQsKwVlQ9Y9s8JJvVFNA5RWP7P1\n6PL+nb5MVKILbwKvlTG9PykLMtS5Y8B0OSyMaHEYCf4tEBhgti5jqJ9t0acEKZNp\nQ7g79SdjjY6/X//nnZyk9z0xCh7iiOkdrS2Dq5IhcN/pfv6JEPKM3uJIklXRT/uy\nCc3RhsJjAgMBAAECggEAPAKsFc0Uh+ailiCs97avs8oyj86TPu8gZ/Tw6+uMvxVF\np68hwJ+fjZ4YqwjD4c8hOTNQiFe6X6D7AT/+W0QuAx8azDdxklSTsTXtvQ50TbEC\nef+zic1sEd9xkUwC9VsjfXQoUM3498/AxhodQ5dR/HMXP9LxFIzm6pcZ5dxMc29q\n+0CSorzte7nHy9SHJ2n42ZFmJpwFfoNjyO+OjKEaOoDNbm3GpDtf78mNs9+jcqyE\nI+rzokH2vSV/eFHFFYWAgHOEBB9i0WtbMV/qmyuWUq3lOw+eK6gId8gzaHjKGOr8\nhWYu6DV1dGPth71R0EWa88T+7hFWHRsYM2wdWhVjRQKBgQD//uMqz1QzfUHuO0b/\nBMaerw9gbtJ/8734U0q+qGnqJgAmhII9SeWf3qwGXt7J89rA2sSegqnxOyuUfnLw\nhAY7TfMcN3sB580tRmXbr3Zx+kz7gw9cdjqi9StRCTep5vwfXIVB0BRZ9in2A1+S\nSuRMCWdA3D080CF5j15Zi78iBQKBgQDcSpMo7Vbk4nSFmc/yHai3lNNa7PkBennX\nnsGDplrY0pybtvFmy8kw6ESbxDRy5XuYHcm0r4WwTiSV+kbmuwEB1UMyKNUk0Ogx\n2JM6Sc1FjnkUNwEtDLXJu5otkw2L81qjengiq90rZS3ktLEDKKN1pfXYmTPHUQvn\ndDtxFiR3RwKBgCR0svskvXP7sYjwriKhFnwAqCrufVG1b2dOzUUrjLHIqZrSog2C\nWY4T0uGxXv7ZmFyAiyGbsAHnkEQ8Ybf4xT5q0mVBTWYvEZwR+212pmKC57Wlq2la\neO0+BuYqbt/mQh9hOKTvsgZBtSYQwup9edeOO0MUWjAv36SFE0WjThvVAoGBAKQM\nsTyISu6WqdmYauBOMAfOv/r1gJYWREhLhKbqqrrPVSss+ObpmcFfJ0Csw7ZQqVLl\n1AFHuRJLjzlVMZm/54ca7ziaaehJ3rDILRP6Q/Cpogdo0upejb5WhAGugicXqgcW\nPALt4/3eEmhAG5ZTnC8P0V5k8Mdc1rWdvGqB59QfAoGAfA+BMfq+fpO7xItvY1t5\nqyFe9S1czzt49YChX+gUpY/odzJC2pyCKAm0nly+gt0gV2/sb5knEmAniSeJ0xKz\nl2OMOOn6Aok5kclKIk+12MSkfY/mkYFN/GMjl0gwk69i3fr+ZmVcE54BaVBsSnlP\n/E6UGQnUW9LMZ5QBLIbwPFk=\n-----END PRIVATE KEY-----\n",
  "client_email": "vision-service-account@connectcare-445200.iam.gserviceaccount.com",
  "client_id": "111709489632121584450",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/vision-service-account%40connectcare-445200.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''');

      final scopes = [vision.VisionApi.cloudPlatformScope];
      final httpClient =
          await clientViaServiceAccount(accountCredentials, scopes);
      final visionApi = vision.VisionApi(httpClient);

      final batchRequest = vision.BatchAnnotateImagesRequest(requests: [
        vision.AnnotateImageRequest(
          image: vision.Image(content: base64Image),
          features: [vision.Feature(type: "DOCUMENT_TEXT_DETECTION")],
        )
      ]);

      final response = await visionApi.images.annotate(batchRequest);

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
        print("Texto detectado (CLUES): $detectedText");
      } else {
        print("No se recibió una respuesta válida de la API de Vision.");
        _invalidApiResponse();
      }

      // Subimos la imagen original a Cloudinary
      final secureUrl = await _uploadImageToCloudinary(fileBytesOriginal);

      // Guardamos CLUES en SharedPreferences (opcional)
      if (detectedText != null &&
          detectedText != "No se detectó código CLUES.") {
        print("Guardando el CLUES en SharedPreferences: $detectedText");
        _sharedPreferencesService.saveClues(detectedText!);
      } else {
        print("No se detectó CLUES válido, no se guarda en SharedPreferences.");
      }

      // Llamamos a la función para registrar la solicitud en el back
      await _registrarSolicitudHospital(detectedText, secureUrl);
    } catch (e) {
      debugPrint("Error al analizar el archivo: $e");
      _errorParsingFile(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Clues'.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Center(
                  child: Text(
                    'Now you must upload the image of the CLUES certificate, it is important that it is legible and clear.'.tr(),
                    style: TextStyle(fontSize: 16),
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
              child: Text('Upload'.tr()),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            if (detectedText != null) ...[
              const SizedBox(height: 20),
              Text(
                'Texto detectado:'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    showCustomSnackBar(context, "Error al seleccionar el archivo: $e".tr());
  }

  void _invalidApiResponse() {
    showCustomSnackBar(
      context,
      "No se recibió una respuesta válida de la API.",
    );
  }

  void _errorParsingFile(e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error al analizar el archivo: $e".tr()),
      ),
    );
  }
}
