import 'package:connectcare/presentation/screens/admin/info_report.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectableCalendar extends StatefulWidget {
  const SelectableCalendar({super.key});

  @override
  State<SelectableCalendar> createState() => _SelectableCalendarState();
}

class _SelectableCalendarState extends State<SelectableCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:
              brightness == Brightness.dark ? Colors.transparent : Colors.white,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 30),
          ),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _selectedDate = selectedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Color.fromARGB(255, 154, 209, 255),
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: Color.fromARGB(255, 200, 92, 184),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              titleTextStyle: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {'selectedDate': _selectedDate});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: Text('Seleccionar fecha'.tr()),
          ),
        ],
      ),
    );
  }
}

class SelectableCalendarPush extends StatefulWidget {
  const SelectableCalendarPush({super.key});

  @override
  State<SelectableCalendarPush> createState() => _SelectableCalendarPushState();
}

class _SelectableCalendarPushState extends State<SelectableCalendarPush> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  final DateTime _firstAllowedDay = DateTime.now().subtract(Duration(days: 30));
  final DateTime _lastAllowedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TableCalendar(
          firstDay: _firstAllowedDay,
          lastDay: _lastAllowedDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (selectedDay.isAfter(_lastAllowedDay) ||
                selectedDay.isBefore(_firstAllowedDay)) {
              return;
            }
            setState(() {
              _focusedDay = focusedDay;
              _selectedDate = selectedDay;
            });
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: Color.fromARGB(255, 154, 209, 255),
              shape: BoxShape.circle,
            ),
            todayDecoration: const BoxDecoration(
              color: Color.fromARGB(255, 200, 92, 184),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            titleTextStyle: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        ElevatedButton(
          onPressed: _selectedDate == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ViewDailyReport(date: _selectedDate!)),
                  );
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: Text('View Daily Report From'.tr(args: [
            _selectedDate != null
                ? DateFormat('dd/MM/yy').format(_selectedDate!)
                : ''
          ])),
        ),
      ],
    );
  }
}
