import 'package:connectcare/core/models/hospital.dart';
import 'package:connectcare/data/repositories/table/clues_repository.dart';
import 'package:connectcare/data/repositories/table/hospital_repository.dart';
import 'package:flutter/material.dart';

class HospitalNameScreen extends StatefulWidget {
  final String detectedText;

  const HospitalNameScreen({super.key, required this.detectedText});

  @override
  _HospitalNameScreen createState() => _HospitalNameScreen();
}

class _HospitalNameScreen extends State<HospitalNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool isButtonEnabled = false;

  final HospitalRepository _hospitalRepository = HospitalRepository();
  final CluesRegistrosRepository _cluesRegistrosRepository =
      CluesRegistrosRepository();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        isButtonEnabled = _nameController.text.isNotEmpty;
      });
    });
  }

  Future<void> _registerHospital() async {
    try {
      final cluesData =
          await _cluesRegistrosRepository.getByClues(widget.detectedText);
      if (cluesData != null) {
        final hospital = Hospital(
          clues: cluesData['clues'] ?? '',
          colonia:
              '${cluesData['tipo_asentamiento'] ?? ''} ${cluesData['asentamiento'] ?? ''}'
                  .trim(),
          estatus: cluesData['estatus_operacion'] ?? '',
          cp: cluesData['codigo_postal']?.toString() ?? '',
          calle:
              '${cluesData['tipo_vialidad'] ?? ''} ${cluesData['vialidad'] ?? ''}'
                  .trim(),
          numeroCalle: cluesData['numero_exterior'] ?? '',
          estado: cluesData['entidad'] ?? '',
          municipio: cluesData['municipio'] ?? '',
          nombre: _nameController.text,
        );

        await _hospitalRepository.insert(hospital.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospital registrado exitosamente.'),
          ),
        );
        Navigator.pushNamed(context, '/adminHomeScreen');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró un registro de CLUES válido.'),
          ),
        );
      }
    } catch (e) {
      print('Error al registrar el hospital: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar el hospital: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nombre del Hospital'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Ahora debes agregar un nombre al hospital, procura ser lo más claro posible.\nEj. IMSS Clinica 14',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ingresa el nombre del hospital',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () async {
                      await _registerHospital();
                    }
                  : null,
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}
