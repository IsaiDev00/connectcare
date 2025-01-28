import 'package:connectcare/core/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';

class DeniedHospitalScreen extends StatefulWidget {
  final String? mensaje;
  final String? fecha;

  const DeniedHospitalScreen({
    super.key,
    required this.mensaje,
    required this.fecha,
  });

  @override
  _DeniedHospitalScreenState createState() => _DeniedHospitalScreenState();
}

class _DeniedHospitalScreenState extends State<DeniedHospitalScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  String formatFecha(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty) {
      return 'No date available.'.tr();
    }
    try {
      final parsedDate = DateTime.parse(fechaStr);
      // Formatear la fecha como YYYY-MM-DD
      return '${parsedDate.year.toString().padLeft(4, '0')}-'
          '${parsedDate.month.toString().padLeft(2, '0')}-'
          '${parsedDate.day.toString().padLeft(2, '0')}';
    } catch (e) {
      // Si falla el parseo, devolver el string original o un mensaje de error
      return fechaStr;
    }
  }

  Future<void> _handleGoBack() async {
    // Obtener el clues desde SharedPreferences
    final clues = await _sharedPreferencesService.getClues();
    if (clues == null) {
      print('No se encontró clues en SharedPreferences.');
      // Si no hay clues, simplemente limpiar y navegar
      _sharedPreferencesService.clearClues();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DynamicWrapper(),
        ),
      );
      return;
    }

    // Construir la URL para DELETE
    final url = Uri.parse('$baseUrl/hospital/solicitudHospital/$clues');

    try {
      // Realizar la solicitud DELETE al servidor
      final response = await http.delete(url);

      print(
          'Respuesta DELETE del servidor: ${response.statusCode} - ${response.body}');

      // Opcional: Puedes manejar el resultado de la eliminación si es necesario.
    } catch (e) {
      print('Error al eliminar la solicitud: $e');
      // Opcional: manejar error en eliminación
    }

    // Limpiar el clues de SharedPreferences
    _sharedPreferencesService.clearClues();

    // Navegar a DynamicWrapper
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DynamicWrapper(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedFecha = formatFecha(widget.fecha);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Request Denied'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                'Your hospital request was not accepted.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reason given:'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.mensaje?.isNotEmpty == true
                  ? widget.mensaje!
                  : 'No message was provided.',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Date of denial:'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formattedFecha,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleGoBack,
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
