import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ProcedureScheduleScreen extends StatefulWidget {
  const ProcedureScheduleScreen({super.key});

  @override
  State<ProcedureScheduleScreen> createState() =>
      _ProcedureScheduleScreenState();
}

class _ProcedureScheduleScreenState extends State<ProcedureScheduleScreen> {
  // Para manejar las pestañas (Scheduled / Add)
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Servicios
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  // -------------------- LISTA DE PROCEDIMIENTOS AGENDADOS ACTIVOS --------------------
  List<Map<String, dynamic>> _scheduledProcedures = [];

  // -------------------- LISTA DE PROCEDIMIENTOS YA TERMINADOS --------------------
  List<Map<String, dynamic>> _finishedProcedures = [];

  // -------------------- DATA DESDE EL BACKEND --------------------
  List<Map<String, dynamic>> _procedures = [];
  Map<String, dynamic>? _selectedProcedure;

  List<Map<String, dynamic>> _salas = [];
  Map<String, dynamic>? _selectedSala;

  Map<String, dynamic>? _salaSchedule;
  DateTime? _selectedDate;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic>? _selectedPatient;

  // Nuevo campo: urgencia
  final List<String> _priorityOptions = ['urgente', 'prioritario', 'normal'];
  String? _selectedPriority;

  String? _doctorId;

  // Para manejar la selección de slots en 30 min
  List<Map<String, DateTime>> _timeSlots = [];
  int? _selectedSlotStartIndex;
  int? _selectedSlotEndIndex;

  // Procedimientos del paciente seleccionado
  List<Map<String, dynamic>> _patientProcedures = [];
  // Conflictos en la sala
  List<Map<String, dynamic>> _conflicts = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      // Se obtiene el id_personal (doctorId)
      _doctorId = await _sharedPreferencesService.getUserId();

      // 1) Si tenemos doctorId, obtenemos la lista real de procedimientos agendados
      if (_doctorId != null) {
        await _fetchScheduledProcedures(_doctorId!);
      }

      // 2) Se obtiene 'clues' (para cargar procedimientos "base")
      final clues = await _sharedPreferencesService.getClues();
      await _fetchProcedures(clues);

      // 3) Se obtienen los pacientes del doctor
      if (_doctorId != null) {
        await _fetchPatients(_doctorId!);
      }
    } catch (e) {
      debugPrint('Error en _fetchInitialData: $e');
    }
  }

  // -------------------------------------------------------------------------
  // OBTENER TODOS LOS PROCEDIMIENTOS AGENDADOS DE LOS PACIENTES DEL DOCTOR
  // -------------------------------------------------------------------------
  Future<void> _fetchScheduledProcedures(String doctorId) async {
    try {
      final url =
          '$baseUrl/agenda_procedimiento/procedimientosMedico/$doctorId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Limpiamos listas
        _scheduledProcedures.clear();
        _finishedProcedures.clear();

        for (var item in data) {
          /*
          item['fecha'] podría traer algo como "2025-01-20T00:00:00.000Z"
          en lugar de solo "2025-01-20". Hacemos substring(0, 10) para
          quedarnos con YYYY-MM-DD y así evitar el FormatException.
          También esperamos que venga item['procedimiento_nombre'] con el nombre.
          Además, se espera que venga item['paciente_nombre'] con el nombre completo del paciente.
        */
          final String fullDateStr = item['fecha'];
          if (fullDateStr.length < 10) {
            debugPrint('Fecha inválida: $fullDateStr');
            continue;
          }

          final String datePart = fullDateStr.substring(0, 10); // "YYYY-MM-DD"
          final arrDate = datePart.split('-');
          if (arrDate.length < 3) {
            debugPrint('No se pudo parsear la fecha: $datePart');
            continue;
          }

          final int y = int.parse(arrDate[0]);
          final int m = int.parse(arrDate[1]);
          final int d = int.parse(arrDate[2]);
          final dateParsed = DateTime(y, m, d);

          // Parse de hora_inicio y hora_fin a TimeOfDay
          final startStr = item['hora_inicio'] as String; // "HH:MM:SS"
          final endStr = item['hora_fin'] as String; // "HH:MM:SS"

          final startArr = startStr.split(':');
          if (startArr.length < 2) continue;
          final TimeOfDay startTime = TimeOfDay(
            hour: int.parse(startArr[0]),
            minute: int.parse(startArr[1]),
          );

          final endArr = endStr.split(':');
          if (endArr.length < 2) continue;
          final TimeOfDay endTime = TimeOfDay(
            hour: int.parse(endArr[0]),
            minute: int.parse(endArr[1]),
          );

          // Convertimos "dateParsed + endTime" a DateTime para saber si ya finalizó
          final endDateTime = DateTime(
            y,
            m,
            d,
            endTime.hour,
            endTime.minute,
          );

          // Checamos si endDateTime está en el futuro (isAfter(DateTime.now()) => no ha acabado)
          final now = DateTime.now();

          // Mapeamos los datos al formato que usamos
          // -> Se asume que en el backend devolvimos "procedimiento_nombre" y "paciente_nombre"
          final procedureName = item['procedimiento_nombre'] ?? 'Sin nombre';
          final pacienteNombre =
              item['paciente_nombre'] ?? 'Nombre Desconocido';

          final mapped = {
            'procedureName': procedureName,
            'date': dateParsed,
            'startTime': startTime,
            'endTime': endTime,
            'patientName': pacienteNombre, // Cambio aquí
            'priority': item['prioridad'],
          };

          if (endDateTime.isAfter(now)) {
            // Todavía activo
            _scheduledProcedures.add(mapped);
          } else {
            // Ya terminó
            _finishedProcedures.add(mapped);
          }
        }

        setState(() {});
      } else {
        debugPrint(
            'Error fetching scheduled procedures: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching scheduled procedures: $e');
    }
  }

  Future<void> _fetchProcedures(String? clues) async {
    if (clues == null) return;
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/procedimiento/$clues'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> proceduresList = data.map((item) {
          return {
            'id_procedimiento': item['id_procedimiento'],
            'nombre': item['nombre'],
            'descripcion': item['descripcion'],
            'cantidad_enfermeros': item['cantidad_enfermeros'],
            'cantidad_medicos': item['cantidad_medicos'],
          };
        }).toList();
        setState(() {
          _procedures = proceduresList;
        });
      } else {
        debugPrint(
            'Error fetching procedures. Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching procedures: $e');
    }
  }

  Future<void> _fetchSalas(int idProcedimiento) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sala_procedimiento/procedimiento/$idProcedimiento'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['sala'] != null && data['sala'] is List) {
          final List<dynamic> salasList = data['sala'];
          setState(() {
            _salas = salasList.map((item) {
              return {
                'id_sala': item['id_sala'],
                'nombre': item['nombre'],
                'numero': item['numero'],
              };
            }).toList();
          });
        } else {
          setState(() {
            _salas = [];
          });
        }
      } else {
        debugPrint(
            'Error fetching salas. Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching salas: $e');
    }
  }

  Future<void> _fetchSchedule(int idSala) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sala/sala/$idSala'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _salaSchedule = data;
        });
      } else {
        debugPrint(
            'Error fetching sala schedule. Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching sala schedule: $e');
    }
  }

  Future<void> _fetchPatients(String doctorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assign_tasks/doctor/patients/$doctorId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _patients = data.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'bed_number': item['bed_number'],
              'age': item['age'],
            };
          }).toList();
        });
      } else {
        debugPrint(
            'Error fetching patients. Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching patients: $e');
    }
  }

  Future<void> _fetchPatientProcedures(int nss) async {
    final dio = Dio();
    final url = '$baseUrl/agenda_procedimiento/procedimientosPaciente/$nss';

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> rawData = response.data;

        final List<Map<String, dynamic>> parsedProcedures = rawData.map((item) {
          final DateTime dtFull = DateTime.parse(item['fecha']);
          final DateTime onlyDate =
              DateTime(dtFull.year, dtFull.month, dtFull.day);

          return {
            'fecha': DateFormat('yyyy-MM-dd').format(onlyDate),
            'hora_inicio': item['hora_inicio'],
            'hora_fin': item['hora_fin'],
            'id_sala': item['id_sala'],
            'id_procedimiento': item['id_procedimiento'],
            'prioridad': item['prioridad'],
          };
        }).toList();

        setState(() {
          _patientProcedures = parsedProcedures;
        });

        debugPrint('Todos los procedimientos: $_patientProcedures');
      } else {
        debugPrint('Error al obtener procedimientos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Excepción al obtener procedimientos: $e');
    }
  }

  Future<void> _fetchConflicts() async {
    if (_selectedProcedure == null ||
        _selectedSala == null ||
        _selectedDate == null) {
      return;
    }
    final body = {
      "id_procedimiento": _selectedProcedure!['id_procedimiento'],
      "id_sala": _selectedSala!['id_sala'],
      "fecha": DateFormat('yyyy-MM-dd').format(_selectedDate!)
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agenda_procedimiento/conflictos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['conflictos'] != null) {
          setState(() {
            _conflicts = List<Map<String, dynamic>>.from(data['conflictos']);
          });
        } else {
          setState(() {
            _conflicts = [];
          });
        }
      } else {
        debugPrint(
            'Error al obtener conflictos. Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching conflicts: $e');
    }
  }

  Future<void> _selectPatient() async {
    String searchQuery = '';
    List<Map<String, dynamic>> filteredPatients = List.from(_patients);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Selecciona un Paciente'.tr()),
              content: SingleChildScrollView(
                // Asegura que el contenido sea desplazable
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar paciente',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                          filteredPatients = _patients.where((patient) {
                            final name =
                                patient['name'].toString().toLowerCase();
                            return name.contains(searchQuery);
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.maxFinite,
                      height: 300, // Ajusta la altura según sea necesario
                      child: filteredPatients.isNotEmpty
                          ? ListView.builder(
                              itemCount: filteredPatients.length,
                              itemBuilder: (context, index) {
                                final patient = filteredPatients[index];
                                return ListTile(
                                  title: Text(patient['name']),
                                  subtitle: Text('NSS: ${patient['id']}'),
                                  onTap: () {
                                    setState(() {
                                      _selectedPatient = patient;
                                      _patientProcedures = [];
                                      _conflicts = [];
                                      _selectedProcedure = null;
                                      _selectedSala = null;
                                      _salaSchedule = null;
                                      _selectedDate = null;
                                      _selectedPriority = null;
                                      _startTime = null;
                                      _endTime = null;
                                      _timeSlots = [];
                                      _selectedSlotStartIndex = null;
                                      _selectedSlotEndIndex = null;
                                    });
                                    Navigator.of(context).pop();
                                    _fetchPatientProcedures(patient['id']);
                                  },
                                );
                              },
                            )
                          : const Center(
                              child: Text('No se encontraron pacientes.'),
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );

    setState(() {}); // Actualizar la UI después de la selección
  }

  Future<void> _selectProcedure() async {
    String searchQuery = '';
    List<Map<String, dynamic>> filteredProcedures = List.from(_procedures);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Selecciona un Procedimiento'.tr()),
              content: SingleChildScrollView(
                // Manejar el desbordamiento dinámico
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar procedimiento',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                          filteredProcedures = _procedures.where((procedure) {
                            final name =
                                procedure['nombre'].toString().toLowerCase();
                            return name.contains(searchQuery);
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.maxFinite,
                      height: 300, // Ajusta la altura según sea necesario
                      child: filteredProcedures.isNotEmpty
                          ? ListView.builder(
                              itemCount: filteredProcedures.length,
                              itemBuilder: (context, index) {
                                final procedure = filteredProcedures[index];
                                return ListTile(
                                  title: Text(procedure['nombre']),
                                  subtitle: Text(
                                      'ID: ${procedure['id_procedimiento']}'),
                                  onTap: () {
                                    setState(() {
                                      _selectedProcedure = procedure;
                                      _selectedSala = null;
                                      _salaSchedule = null;
                                      _selectedDate = null;
                                      _startTime = null;
                                      _endTime = null;
                                      _selectedPriority = null;
                                      _timeSlots = [];
                                      _selectedSlotStartIndex = null;
                                      _selectedSlotEndIndex = null;
                                      _conflicts = [];
                                    });
                                    Navigator.of(context).pop();
                                    _fetchSalas(procedure['id_procedimiento']);
                                  },
                                );
                              },
                            )
                          : const Center(
                              child: Text('No se encontraron procedimientos.'),
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar'.tr()),
                ),
              ],
            );
          },
        );
      },
    );

    setState(() {}); // Actualizar la UI después de la selección
  }

  int _priorityRank(String prio) {
    switch (prio.toLowerCase()) {
      case 'urgente':
        return 3;
      case 'prioritario':
        return 2;
      default:
        return 1;
    }
  }

  bool _isSlotInConflict(DateTime slotStart, DateTime slotEnd) {
    bool overlaps(
        DateTime startA, DateTime endA, DateTime startB, DateTime endB) {
      return startA.isBefore(endB) && startB.isBefore(endA);
    }

    // 1) Bloqueo por procedimientos del propio paciente (sin importar prioridad)
    for (final proc in _patientProcedures) {
      final fecha = DateTime.parse(proc['fecha']).toLocal();
      if (_isSameDate(fecha, slotStart)) {
        final hi = (proc['hora_inicio'] as String).split(':');
        final hf = (proc['hora_fin'] as String).split(':');
        final startP = DateTime(
          fecha.year,
          fecha.month,
          fecha.day,
          int.parse(hi[0]),
          int.parse(hi[1]),
        );
        final endP = DateTime(
          fecha.year,
          fecha.month,
          fecha.day,
          int.parse(hf[0]),
          int.parse(hf[1]),
        );
        if (overlaps(slotStart, slotEnd, startP, endP)) {
          return true;
        }
      }
    }

    // 2) Bloqueo por conflictos en la sala, según prioridad
    if (_selectedPriority != null) {
      final int docPrioRank = _priorityRank(_selectedPriority!);

      for (final c in _conflicts) {
        final int conflictPrioRank = _priorityRank(c['prioridad']);
        if (conflictPrioRank >= docPrioRank) {
          final hi = (c['hora_inicio'] as String).split(':');
          final hf = (c['hora_fin'] as String).split(':');
          final startC = DateTime(
            slotStart.year,
            slotStart.month,
            slotStart.day,
            int.parse(hi[0]),
            int.parse(hi[1]),
          );
          final endC = DateTime(
            slotStart.year,
            slotStart.month,
            slotStart.day,
            int.parse(hf[0]),
            int.parse(hf[1]),
          );
          if (overlaps(slotStart, slotEnd, startC, endC)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ---------------------------------------------------------------------------
  // LISTA DE PROCEDIMIENTOS ACTIVOS
  // ---------------------------------------------------------------------------
  Widget _buildScheduledList(BuildContext context) {
    if (_scheduledProcedures.isEmpty) {
      return const Center(
        child: Text(
          'No scheduled procedures',
          style: TextStyle(fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      itemCount: _scheduledProcedures.length,
      itemBuilder: (context, index) {
        final item = _scheduledProcedures[index];
        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AHORA MOSTRAMOS EL NOMBRE REAL:
              Text(
                'Procedure: ${item['procedureName']}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Date: ${DateFormat('yyyy-MM-dd').format(item['date'])}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Time: ${_formatTime(item['startTime'])} - ${_formatTime(item['endTime'])}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Patient: ${item['patientName']}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Priority: ${item['priority']}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 5),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // LISTA DE PROCEDIMIENTOS YA FINALIZADOS (se mostrará en un dialog)
  // ---------------------------------------------------------------------------
  Widget _buildFinishedList(BuildContext context) {
    if (_finishedProcedures.isEmpty) {
      return const Center(
        child: Text(
          'No finished procedures',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView.builder(
        itemCount: _finishedProcedures.length,
        itemBuilder: (context, index) {
          final item = _finishedProcedures[index];
          return ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Procedure: ${item['procedureName']}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(item['date'])}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Time: ${_formatTime(item['startTime'])} - ${_formatTime(item['endTime'])}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Patient: ${item['patientName']}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Priority: ${item['priority']}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                const Divider(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTÓN PARA MOSTRAR PROCEDIMIENTOS TERMINADOS
  // ---------------------------------------------------------------------------
  void _showFinishedProcedures() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Finished Procedures'),
          content: _buildFinishedList(context),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'.tr()),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UTILS
  // ---------------------------------------------------------------------------
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  // ---------------------------------------------------------------------------
  // GENERAR SLOTS
  // ---------------------------------------------------------------------------
  void _generateTimeSlots() {
    if (_salaSchedule == null || _selectedDate == null) {
      _timeSlots = [];
      return;
    }
    final horario = _salaSchedule!['horarioAtencion'];
    if (horario == null) {
      _timeSlots = [];
      return;
    }
    String? diaKey = _weekdayToSpanishKey(_selectedDate!.weekday);
    if (diaKey == null) {
      _timeSlots = [];
      return;
    }
    final inicioStr = horario['${diaKey}_hora_inicio'];
    final finStr = horario['${diaKey}_hora_fin'];
    if (inicioStr == null || finStr == null) {
      _timeSlots = [];
      return;
    }

    final inicioParts = inicioStr.split(':');
    final finParts = finStr.split(':');
    final startHour = int.tryParse(inicioParts[0]) ?? 0;
    final startMinute = int.tryParse(inicioParts[1]) ?? 0;
    final endHour = int.tryParse(finParts[0]) ?? 23;
    final endMinute = int.tryParse(finParts[1]) ?? 59;

    final dayStart = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      startHour,
      startMinute,
    );
    final dayEnd = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      endHour,
      endMinute,
    );

    if (dayEnd.isBefore(dayStart)) {
      _timeSlots = [];
      return;
    }

    final List<Map<String, DateTime>> slots = [];
    DateTime current = dayStart;
    const int intervalMinutes = 30;

    while (current.isBefore(dayEnd)) {
      final next = current.add(const Duration(minutes: intervalMinutes));
      final slotEnd = next.isAfter(dayEnd) ? dayEnd : next;
      slots.add({'start': current, 'end': slotEnd});
      current = slotEnd;
    }

    _timeSlots = slots;
  }

  Widget _buildTimeSlotSelector() {
    _generateTimeSlots();

    if (_timeSlots.isEmpty) {
      return Text(
        'Sin intervalos de tiempo disponibles'.tr(),
        style: TextStyle(fontSize: 14),
      );
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: _timeSlots.length,
        itemBuilder: (context, index) {
          final slot = _timeSlots[index];
          final slotStart = slot['start']!;
          final slotEnd = slot['end']!;
          final slotLabel =
              '${DateFormat('HH:mm').format(slotStart)} - ${DateFormat('HH:mm').format(slotEnd)}';

          bool isSelected = false;
          if (_selectedSlotStartIndex != null &&
              _selectedSlotEndIndex != null) {
            if (index >= _selectedSlotStartIndex! &&
                index <= _selectedSlotEndIndex!) {
              isSelected = true;
            }
          } else if (_selectedSlotStartIndex != null &&
              _selectedSlotEndIndex == null) {
            if (index == _selectedSlotStartIndex) {
              isSelected = true;
            }
          }

          bool inConflict = _isSlotInConflict(slotStart, slotEnd);

          return ListTile(
            title: Text(
              slotLabel,
              style: TextStyle(
                fontSize: 14,
                color: inConflict
                    ? Colors.red
                    : (isSelected ? Colors.blue : Colors.black),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: inConflict
                ? null
                : () {
                    setState(() {
                      if (_selectedSlotStartIndex == null) {
                        _selectedSlotStartIndex = index;
                        _selectedSlotEndIndex = null;
                      } else if (_selectedSlotEndIndex == null) {
                        if (index >= _selectedSlotStartIndex!) {
                          _selectedSlotEndIndex = index;
                        } else {
                          _selectedSlotStartIndex = index;
                        }
                      } else {
                        _selectedSlotStartIndex = index;
                        _selectedSlotEndIndex = null;
                      }

                      if (_selectedSlotStartIndex != null &&
                          _selectedSlotEndIndex != null) {
                        final startSlot = _timeSlots[_selectedSlotStartIndex!];
                        final endSlot = _timeSlots[_selectedSlotEndIndex!];
                        _startTime = TimeOfDay(
                          hour: startSlot['start']!.hour,
                          minute: startSlot['start']!.minute,
                        );
                        _endTime = TimeOfDay(
                          hour: endSlot['end']!.hour,
                          minute: endSlot['end']!.minute,
                        );
                      } else {
                        _startTime = null;
                        _endTime = null;
                      }
                    });
                  },
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    if (_salaSchedule == null) return;
    final horario = _salaSchedule!['horarioAtencion'];
    if (horario == null) return;

    DateTime now = DateTime.now();
    DateTime lastDate = DateTime(now.year + 1);

    bool mySelectableDayPredicate(DateTime day) {
      if (day.isBefore(DateTime(now.year, now.month, now.day))) {
        return false;
      }
      String? diaKey = _weekdayToSpanishKey(day.weekday);
      if (diaKey == null) return false;

      final inicio = horario['${diaKey}_hora_inicio'];
      final fin = horario['${diaKey}_hora_fin'];
      if (inicio == null || fin == null) {
        return false;
      }
      return true;
    }

    DateTime validInitialDate = now;
    while (true) {
      if (validInitialDate.isAfter(lastDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay fechas disponibles.')),
        );
        return;
      }
      if (mySelectableDayPredicate(validInitialDate)) {
        break;
      }
      validInitialDate = validInitialDate.add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: validInitialDate,
      firstDate: now,
      lastDate: lastDate,
      selectableDayPredicate: mySelectableDayPredicate,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _timeSlots = [];
        _selectedSlotStartIndex = null;
        _selectedSlotEndIndex = null;
        _startTime = null;
        _endTime = null;
      });

      await _fetchConflicts();
    }
  }

  String? _weekdayToSpanishKey(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'lunes';
      case DateTime.tuesday:
        return 'martes';
      case DateTime.wednesday:
        return 'miercoles';
      case DateTime.thursday:
        return 'jueves';
      case DateTime.friday:
        return 'viernes';
      case DateTime.saturday:
        return 'sabado';
      case DateTime.sunday:
        return 'domingo';
    }
    return null;
  }

  Future<void> _scheduleProcedure() async {
    if (!canSchedule) return;

    final message = '''
---- Datos recopilados ----
Procedimiento: ${_selectedProcedure!['nombre']} (ID: ${_selectedProcedure!['id_procedimiento']})
Sala: ${_selectedSala!['nombre']} (ID: ${_selectedSala!['id_sala']})
Fecha seleccionada: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}
Hora inicio: ${_startTime?.format(context)}
Hora fin: ${_endTime?.format(context)}
Paciente: ${_selectedPatient!['name']} (NSS: ${_selectedPatient!['id']})
Urgencia: ${_selectedPriority ?? 'No seleccionado'}
--------------------------------
''';
    debugPrint(message);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos recopilados. Revisa el log para más detalles.'),
      ),
    );

    String timeOfDayToString(TimeOfDay t) {
      final hour = t.hour.toString().padLeft(2, '0');
      final minute = t.minute.toString().padLeft(2, '0');
      return '$hour:$minute:00';
    }

    final body = {
      'fecha': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'id_procedimiento': _selectedProcedure!['id_procedimiento'],
      'id_sala': _selectedSala!['id_sala'],
      'hora_inicio': timeOfDayToString(_startTime!),
      'hora_fin': timeOfDayToString(_endTime!),
      'prioridad': _selectedPriority,
      'nss_paciente': _selectedPatient!['id'],
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agenda_procedimiento/agendarAutoReagendar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Procedimiento agendado con éxito.'),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DynamicWrapper(),
          ),
        );
      } else {
        debugPrint('Error al agendar: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo agendar el procedimiento. Código: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Excepción al agendar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado al agendar: $e'),
        ),
      );
    }
  }

  bool get canSchedule {
    return _selectedProcedure != null &&
        _selectedSala != null &&
        _selectedDate != null &&
        _startTime != null &&
        _endTime != null &&
        _selectedPatient != null &&
        _selectedPriority != null;
  }

  Widget _buildFormPage(BuildContext context) {
    var theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            'Agendar Procedimiento',
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 20),

          // (1) Selecciona paciente con botón
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1) Selecciona el paciente',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectPatient,
                child: Text(
                  _selectedPatient == null
                      ? 'Seleccionar Paciente'
                      : 'Paciente: ${_selectedPatient!['name']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // (2) Selecciona procedimiento con botón
          Visibility(
            visible: _selectedPatient != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2) Selecciona el procedimiento',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _selectProcedure,
                  child: Text(
                    _selectedProcedure == null
                        ? 'Seleccionar Procedimiento'
                        : 'Procedimiento: ${_selectedProcedure!['nombre']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // (3) Selecciona sala
          Visibility(
            visible: _selectedProcedure != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3) Selecciona la sala',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Aquí puedes mantener el DropdownButton para seleccionar sala
                DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  value: _selectedSala,
                  hint: Text('Sala'.tr(), style: TextStyle(fontSize: 14)),
                  items: _salas.map((sala) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: sala,
                      child: Text(
                        '${sala['nombre']} (#${sala['numero']})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() {
                      _selectedSala = value;
                      _salaSchedule = null;
                      _selectedDate = null;
                      _startTime = null;
                      _endTime = null;
                      _selectedPriority = null;
                      _timeSlots = [];
                      _selectedSlotStartIndex = null;
                      _selectedSlotEndIndex = null;
                      _conflicts = [];
                    });
                    await _fetchSchedule(value['id_sala']);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // (4) Selecciona urgencia
          Visibility(
            visible: _selectedSala != null && _salaSchedule != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4) Selecciona la urgencia',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedPriority,
                  hint: Text('Urgencia'.tr(), style: TextStyle(fontSize: 14)),
                  items: _priorityOptions.map((urgency) {
                    return DropdownMenuItem<String>(
                      value: urgency,
                      child:
                          Text(urgency, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value;
                      _selectedDate = null;
                      _startTime = null;
                      _endTime = null;
                      _timeSlots = [];
                      _selectedSlotStartIndex = null;
                      _selectedSlotEndIndex = null;
                      _conflicts = [];
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // (5) Selecciona fecha
          Visibility(
            visible: _selectedPriority != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '5) Selecciona la fecha disponible',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: Text(
                    _selectedDate == null
                        ? 'Seleccionar fecha'
                        : 'Fecha: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                if (_selectedDate != null) _buildHorarioDisponible(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // (6) Selecciona hora inicio/fin
          Visibility(
            visible: _selectedDate != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '6) Selecciona hora inicio y fin (intervalos de 30 min)',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildTimeSlotSelector(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: canSchedule ? _scheduleProcedure : null,
            child: Text('Schedule Procedure'.tr(),
                style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHorarioDisponible() {
    final horario = _salaSchedule?['horarioAtencion'] ?? {};
    String? diaKey = _weekdayToSpanishKey(_selectedDate!.weekday);
    if (diaKey == null) {
      return Text(
        'Sin horario disponible'.tr(),
        style: TextStyle(fontSize: 14),
      );
    }
    final inicioStr = horario['${diaKey}_hora_inicio'];
    final finStr = horario['${diaKey}_hora_fin'];
    if (inicioStr == null || finStr == null) {
      return Text(
        'Sin horario disponible'.tr(),
        style: TextStyle(fontSize: 14),
      );
    }
    return Text(
      'Horario disponible para este día: $inicioStr - $finStr',
      style: const TextStyle(fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMenuItem('Scheduled'.tr(), 0),
                _buildMenuItem('Add'.tr(), 1),
              ],
            ),
            const Divider(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  // Pestaña 0: Lista de procedimientos activos + Botón "Ver Terminados"
                  Stack(
                    children: [
                      Positioned.fill(
                        child: _buildScheduledList(context),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: ElevatedButton(
                          onPressed: _showFinishedProcedures,
                          child: Text('Show Finished'.tr()),
                        ),
                      ),
                    ],
                  ),

                  // Pestaña 1: Formulario
                  _buildFormPage(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, int index) {
    var theme = Theme.of(context);
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary
              : theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
