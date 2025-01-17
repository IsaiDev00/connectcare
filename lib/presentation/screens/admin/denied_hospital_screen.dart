import 'package:flutter/material.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';

class DeniedHospitalScreen extends StatefulWidget {
  final String? mensaje;
  final String? fecha;

  const DeniedHospitalScreen({
    Key? key,
    required this.mensaje,
    required this.fecha,
  }) : super(key: key);

  @override
  _DeniedHospitalScreen createState() => _DeniedHospitalScreen();
}

class _DeniedHospitalScreen extends State<DeniedHospitalScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  String formatFecha(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty) {
      return 'No date available.';
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

  @override
  Widget build(BuildContext context) {
    final formattedFecha = formatFecha(widget.fecha);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Request Denied'),
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
            const Text(
              'Reason given:',
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
            const Text(
              'Date of denial:',
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
              onPressed: () {
                _sharedPreferencesService.clearClues();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DynamicWrapper(),
                  ),
                );
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
