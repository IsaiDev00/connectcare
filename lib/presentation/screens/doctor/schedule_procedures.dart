import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ProcedureScheduleScreen extends StatefulWidget {
  const ProcedureScheduleScreen({Key? key}) : super(key: key);

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

  // Ejemplo de procedimientos ya agendados (solo para mostrarlos en la otra pestaña)
  final List<Map<String, dynamic>> _scheduledProcedures = [
    {
      'procedureName': 'Cirugía menor',
      'date': DateTime.now().add(const Duration(days: 1)),
      'startTime': const TimeOfDay(hour: 10, minute: 0),
      'endTime': const TimeOfDay(hour: 11, minute: 0),
      'patient': 'Juan Pérez',
      'priority': 'Urgente',
    },
    {
      'procedureName': 'Endoscopia',
      'date': DateTime.now().add(const Duration(days: 2)),
      'startTime': const TimeOfDay(hour: 13, minute: 0),
      'endTime': const TimeOfDay(hour: 14, minute: 0),
      'patient': 'María Rodríguez',
      'priority': 'Normal',
    },
    {
      'procedureName': 'Cura de heridas',
      'date': DateTime.now().add(const Duration(days: 3)),
      'startTime': const TimeOfDay(hour: 9, minute: 0),
      'endTime': const TimeOfDay(hour: 9, minute: 30),
      'patient': 'Carlos Sánchez',
      'priority': 'Prioritario',
    },
  ];

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

  // ---------------------------------------------------------------------
  // NUEVO: variables para manejar los procedimientos agendados del paciente
  //       y los posibles conflictos en la sala.
  // ---------------------------------------------------------------------
  List<Map<String, dynamic>> _patientProcedures = [];
  List<Map<String, dynamic>> _conflicts = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      // Ejemplo: se obtiene el doctorId, si aplica
      _doctorId = await _sharedPreferencesService.getUserId();

      // Se obtiene 'clues'
      final clues = await _sharedPreferencesService.getClues();
      await _fetchProcedures(clues);

      // Se obtienen pacientes
      if (_doctorId != null) {
        await _fetchPatients(_doctorId!);
      }
    } catch (e) {
      debugPrint('Error en _fetchInitialData: $e');
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
      final response = await http.get(Uri.parse(
          '$baseUrl/sala_procedimiento/procedimiento/$idProcedimiento'));
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
      final response = await http
          .get(Uri.parse('$baseUrl/assign_tasks/doctor/patients/$doctorId'));
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

  // ---------------------------------------------------------------------
  // NUEVO: Obtener los procedimientos del paciente (por su NSS)
  // ---------------------------------------------------------------------
  Future<void> _fetchPatientProcedures(int nss) async {
    final url = '$baseUrl/agenda_procedimiento/procedimientosPaciente/$nss';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);

        final List<Map<String, dynamic>> parsedProcedures = rawData.map((item) {
          // 1) Tomamos sólo la parte de fecha "YYYY-MM-DD" ignorando la hora y la Z
          final String fullDateString = item['fecha'];
          // substring(0, 10) => "2025-01-31"
          final String datePart = fullDateString.substring(0, 10);

          // 2) Parseamos esa parte sin que afecte la zona horaria
          final arr = datePart.split('-'); // ["2025","01","31"]
          final y = int.parse(arr[0]);
          final m = int.parse(arr[1]);
          final d = int.parse(arr[2]);
          final onlyDate = DateTime(y, m, d);

          // 3) Retornamos con la fecha ya “forzada” a ese día exacto
          return {
            'fecha':
                onlyDate.toIso8601String(), // e.g. "2025-01-31T00:00:00.000"
            'hora_inicio': item['hora_inicio'],
            'hora_fin': item['hora_fin'],
            'id_sala': item['id_sala'],
            'id_procedimiento': item['id_procedimiento'],
            'prioridad': item['prioridad'],
          };
        }).toList();

        debugPrint(
            "Procedimientos del Paciente (NSS: $nss) => $parsedProcedures");

        setState(() {
          _patientProcedures = parsedProcedures;
        });
      } else if (response.statusCode == 404) {
        debugPrint(
            'El paciente (NSS: $nss) no tiene procedimientos agendados (404).');
        setState(() {
          _patientProcedures = [];
        });
      } else {
        debugPrint('Error al obtener procedimientos del paciente. '
            'Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception fetching patient procedures: $e');
    }
  }

  // ---------------------------------------------------------------------
  // NUEVO: Obtener conflictos en la sala, fecha y procedimiento seleccionados
  // ---------------------------------------------------------------------
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
        // Imprimimos en consola los conflictos recibidos
        debugPrint("Conflictos para la sala/proc/fecha: ${data['conflictos']}");
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

  // Helper para asignar un valor numérico a cada prioridad.
  int _priorityRank(String prio) {
    switch (prio.toLowerCase()) {
      case 'urgente':
        return 3;
      case 'prioritario':
        return 2;
      default: // "normal" u otros
        return 1;
    }
  }

  bool _isSlotInConflict(DateTime slotStart, DateTime slotEnd) {
    // Función auxiliar para comparar superposición
    bool overlaps(
      DateTime startA,
      DateTime endA,
      DateTime startB,
      DateTime endB,
    ) {
      // Se superponen si startA < endB && startB < endA
      return startA.isBefore(endB) && startB.isBefore(endA);
    }

    // PRIMERO: Bloqueo por procedimientos del propio paciente
    // (Siempre se bloquea si se superponen, independientemente de la prioridad)
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
          return true; // Bloquea
        }
      }
    }

    // SEGUNDO: Bloqueo por conflictos en la sala, según prioridad
    // Obtenemos la prioridad del procedimiento que seleccionó el doctor
    final int docPrioRank = _priorityRank(_selectedPriority!);

    for (final c in _conflicts) {
      // c tiene: {"hora_inicio":"08:00:00","hora_fin":"11:30:00","prioridad":"urgente", ...}
      final int conflictPrioRank = _priorityRank(c['prioridad']);

      // Solo bloqueamos si la prioridad del conflicto es >= prioridad del doctor
      // (siguiendo la regla: URGENTE bloquea URGENTE, PRIORITARIO bloquea URGENTE y PRIORITARIO, NORMAL bloquea todo)
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
        // Si se superponen, bloquea
        if (overlaps(slotStart, slotEnd, startC, endC)) {
          return true;
        }
      }
    }

    return false; // Si no cayó en ninguno de los bloqueos, el slot está disponible
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
                'Patient: ${item['patient']}',
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

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  /// Computa los "slots" de 30 min (o el lapso que quede al inicio y al final)
  /// a partir del horario de la sala en la fecha seleccionada.
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

    // Parseamos el horario
    final inicioParts = inicioStr.split(':');
    final finParts = finStr.split(':');
    final startHour = int.tryParse(inicioParts[0]) ?? 0;
    final startMinute = int.tryParse(inicioParts[1]) ?? 0;
    final endHour = int.tryParse(finParts[0]) ?? 23;
    final endMinute = int.tryParse(finParts[1]) ?? 59;

    // Creamos DateTime de inicio y fin
    final dayStart = DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, startHour, startMinute);
    final dayEnd = DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, endHour, endMinute);

    if (dayEnd.isBefore(dayStart)) {
      _timeSlots = [];
      return;
    }

    final List<Map<String, DateTime>> slots = [];
    DateTime current = dayStart;

    const int intervalMinutes = 30;

    while (current.isBefore(dayEnd)) {
      // Próximo slot teórico = current + 30 min
      final next = current.add(const Duration(minutes: intervalMinutes));

      // Si nos pasamos del fin, recortamos
      final slotEnd = next.isAfter(dayEnd) ? dayEnd : next;

      // Agregamos el slot [current, slotEnd]
      slots.add({'start': current, 'end': slotEnd});

      // Avanzamos
      current = slotEnd;
    }

    _timeSlots = slots;
  }

  /// Construye la lista de slots en 30 min para que el usuario pueda
  /// seleccionar un rango (startSlot -> endSlot).
  Widget _buildTimeSlotSelector() {
    // Generamos los slots
    _generateTimeSlots();

    // Si no hay slots, indicamos que no hay nada
    if (_timeSlots.isEmpty) {
      return const Text(
        'Sin intervalos de tiempo disponibles',
        style: TextStyle(fontSize: 14),
      );
    }

    return SizedBox(
      height: 300, // Ajusta la altura para que sea scrolleable
      child: ListView.builder(
        itemCount: _timeSlots.length,
        itemBuilder: (context, index) {
          final slot = _timeSlots[index];
          final slotStart = slot['start']!;
          final slotEnd = slot['end']!;
          final slotLabel =
              '${DateFormat('HH:mm').format(slotStart)} - ${DateFormat('HH:mm').format(slotEnd)}';

          // Determinamos si este slot está en el rango seleccionado
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

          // Determinamos si está en conflicto
          bool inConflict = _isSlotInConflict(slotStart, slotEnd);

          return ListTile(
            title: Text(
              slotLabel,
              style: TextStyle(
                fontSize: 14,
                // Si está en conflicto => rojo
                // Si está seleccionado => azul
                // Caso contrario => negro
                color: inConflict
                    ? Colors.red
                    : (isSelected ? Colors.blue : Colors.black),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: inConflict
                ? null // Bloquear tap si está en conflicto
                : () {
                    setState(() {
                      // Lógica de selección de rango
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

                      // Actualizamos _startTime y _endTime si tenemos un rango completo
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

    bool _mySelectableDayPredicate(DateTime day) {
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
      if (_mySelectableDayPredicate(validInitialDate)) {
        break;
      }
      validInitialDate = validInitialDate.add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: validInitialDate,
      firstDate: now,
      lastDate: lastDate,
      selectableDayPredicate: _mySelectableDayPredicate,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Limpiamos la selección de slots
        _timeSlots = [];
        _selectedSlotStartIndex = null;
        _selectedSlotEndIndex = null;
        _startTime = null;
        _endTime = null;
      });

      // LUEGO DE TENER FECHA, BUSCAMOS CONFLICTOS
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

    // Helper para convertir TimeOfDay a "HH:mm:ss"
    String _timeOfDayToString(TimeOfDay t) {
      final hour = t.hour.toString().padLeft(2, '0');
      final minute = t.minute.toString().padLeft(2, '0');
      return '$hour:$minute:00';
    }

    final body = {
      'fecha': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'id_procedimiento': _selectedProcedure!['id_procedimiento'],
      'id_sala': _selectedSala!['id_sala'],
      'hora_inicio': _timeOfDayToString(_startTime!),
      'hora_fin': _timeOfDayToString(_endTime!),
      'prioridad': _selectedPriority, // "urgente", "prioritario" o "normal"
      'nss_paciente': _selectedPatient!['id'], // Se asume 'id' es el NSS
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agenda_procedimiento/agendar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Procedimiento agendado con éxito.'),
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

          // (1) Selecciona paciente
          Text(
            '1) Selecciona el paciente',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          DropdownButton<Map<String, dynamic>>(
            isExpanded: true,
            value: _selectedPatient,
            hint: const Text('Paciente', style: TextStyle(fontSize: 14)),
            items: _patients.map((patient) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: patient,
                child:
                    Text(patient['name'], style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (value) async {
              setState(() {
                _selectedPatient = value;
                // Reiniciamos lo demás
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

              if (value != null) {
                // Llamamos para obtener los procedimientos del paciente
                final nss = value['id']; // su NSS (según tu backend)
                await _fetchPatientProcedures(nss);
              }
            },
          ),
          const SizedBox(height: 20),

          // (2) Selecciona procedimiento
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
                DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  value: _selectedProcedure,
                  hint: const Text('Procedimiento',
                      style: TextStyle(fontSize: 14)),
                  items: _procedures.map((proc) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: proc,
                      child: Text(proc['nombre'],
                          style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() {
                      _selectedProcedure = value;
                      // Resetear
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
                    await _fetchSalas(value['id_procedimiento']);
                  },
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
                DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  value: _selectedSala,
                  hint: const Text('Sala', style: TextStyle(fontSize: 14)),
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
                  hint: const Text('Urgencia', style: TextStyle(fontSize: 14)),
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

          // Botón
          ElevatedButton(
            onPressed: canSchedule ? _scheduleProcedure : null,
            child: const Text('Schedule Procedure',
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
      return const Text(
        'Sin horario disponible',
        style: TextStyle(fontSize: 14),
      );
    }
    final inicioStr = horario['${diaKey}_hora_inicio'];
    final finStr = horario['${diaKey}_hora_fin'];
    if (inicioStr == null || finStr == null) {
      return const Text(
        'Sin horario disponible',
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
                _buildMenuItem('Scheduled', 0),
                _buildMenuItem('Add', 1),
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
                  _buildScheduledList(context),
                  _buildFormPage(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
