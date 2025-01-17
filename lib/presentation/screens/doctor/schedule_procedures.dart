import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProcedureScheduleScreen extends StatefulWidget {
  const ProcedureScheduleScreen({super.key});

  @override
  State<ProcedureScheduleScreen> createState() =>
      _ProcedureScheduleScreenState();
}

class _ProcedureScheduleScreenState extends State<ProcedureScheduleScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  // Ejemplo de procedimientos ya agendados
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

  // Formulario para agendar nuevo procedimiento
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedProcedure = '';
  String _selectedPriority = '';
  String _selectedPatient = '';

  // Esta lista ya no se define estática. Se llenará con la data del backend.
  List<String> _procedureList = [];

  final List<String> _patientList = [
    'Juan Pérez',
    'María Rodríguez',
    'Carlos Sánchez',
    'Ana Martínez',
    'Pedro López',
  ];
  final List<String> _priorityOptions = ['Urgente', 'Prioritario', 'Normal'];

  final TextEditingController _procedureSearchController =
      TextEditingController();
  List<String> _filteredProcedures = [];

  @override
  void initState() {
    super.initState();
    _filteredProcedures = [];

    // Cargar lista de procedimientos desde el backend
    _fetchProcedures();
  }

  /// Método para obtener la lista de procedimientos desde el backend
  Future<void> _fetchProcedures() async {
    try {
      // Obtengo 'clues' desde shared preferences
      final clues = await _sharedPreferencesService.getClues();

      final response = await http.get(
        Uri.parse('$baseUrl/procedimiento/$clues'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Asumiendo que 'data' es un array de strings
        setState(() {
          _procedureList = data.map((e) => e.toString()).toList();
        });
      } else {
        // Manejo de error en caso de que el statusCode sea distinto de 200
        debugPrint('Error fetching procedures. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception fetching procedures: $e');
    }
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
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      selectableDayPredicate: (day) {
        // Deshabilito sábados y domingos
        if (day.weekday == DateTime.saturday ||
            day.weekday == DateTime.sunday) {
          return false;
        }
        return true;
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTimes() async {
    if (_selectedDate == null) return;

    final TimeOfDay? pickedStart = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (pickedStart == null) return;
    if (pickedStart.hour < 8 || pickedStart.hour > 20) return;

    final TimeOfDay? pickedEnd = await showTimePicker(
      context: context,
      initialTime: pickedStart,
    );
    if (pickedEnd == null) return;
    if (pickedEnd.hour < 8 || pickedEnd.hour > 20) return;

    setState(() {
      _startTime = pickedStart;
      _endTime = pickedEnd;
    });
  }

  void _filterProcedures(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredProcedures = [];
      });
      return;
    }
    setState(() {
      _filteredProcedures = _procedureList
          .where((proc) => proc.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _scheduleProcedure() {
    if (_selectedDate == null ||
        _startTime == null ||
        _endTime == null ||
        _selectedProcedure.isEmpty ||
        _selectedPriority.isEmpty ||
        _selectedPatient.isEmpty) {
      return;
    }
    setState(() {
      _scheduledProcedures.add({
        'procedureName': _selectedProcedure,
        'date': _selectedDate!,
        'startTime': _startTime!,
        'endTime': _endTime!,
        'patient': _selectedPatient,
        'priority': _selectedPriority,
      });
      _selectedDate = null;
      _startTime = null;
      _endTime = null;
      _selectedProcedure = '';
      _selectedPriority = '';
      _selectedPatient = '';
      _procedureSearchController.clear();
      _filteredProcedures = [];
    });
  }

  Widget _buildScheduledList(BuildContext context) {
    var theme = Theme.of(context);
    if (_scheduledProcedures.isEmpty) {
      return Center(
        child: Text(
          'No scheduled procedures',
          style: theme.textTheme.headlineSmall,
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
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                'Date: ${_formatDate(item['date'])}',
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                'Time: ${_formatTime(item['startTime'])} - ${_formatTime(item['endTime'])}',
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                'Patient: ${item['patient']}',
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                'Priority: ${item['priority']}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 5),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormPage(BuildContext context) {
    var theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Center(
            child: Text(
              'Schedule a Procedure',
              style: theme.textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickDate,
            child: Text(_selectedDate == null
                ? 'Select Day'
                : 'Selected: ${_formatDate(_selectedDate!)}'),
          ),
          const SizedBox(height: 10),
          Text(
            'Available schedule: 08:00 - 20:00',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _selectedDate == null ? null : _pickTimes,
            child: Text(
              (_startTime == null || _endTime == null)
                  ? 'Select Start & End Time'
                  : 'Time: ${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _procedureSearchController,
            decoration: const InputDecoration(
              labelText: 'Search Procedure',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => _filterProcedures(val),
          ),
          const SizedBox(height: 10),
          if (_filteredProcedures.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: ListView.builder(
                itemCount: _filteredProcedures.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_filteredProcedures[index]),
                    onTap: () {
                      setState(() {
                        _selectedProcedure = _filteredProcedures[index];
                        _procedureSearchController.clear();
                        _filteredProcedures = [];
                      });
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          if (_selectedProcedure.isNotEmpty)
            Text('Selected Procedure: $_selectedProcedure'),
          const SizedBox(height: 20),
          DropdownButton<String>(
            hint: const Text('Select Priority'),
            value: _selectedPriority.isEmpty ? null : _selectedPriority,
            items: _priorityOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedPriority = val ?? '';
              });
            },
          ),
          const SizedBox(height: 20),
          DropdownButton<String>(
            hint: const Text('Select Patient'),
            value: _selectedPatient.isEmpty ? null : _selectedPatient,
            items: _patientList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedPatient = val ?? '';
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _scheduleProcedure,
            child: const Text('Schedule Procedure'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
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
