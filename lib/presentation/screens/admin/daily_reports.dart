import 'package:connectcare/presentation/widgets/selectable_calendar.dart';
import 'package:flutter/material.dart';

class DailyReports extends StatefulWidget {
  const DailyReports({super.key});

  @override
  State<DailyReports> createState() => _DailyReportsState();
}

class _DailyReportsState extends State<DailyReports> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            Text('Daily reports',
                style: theme.textTheme.headlineLarge!.copyWith(
                  color: theme.colorScheme.onSurface,
                )),
            SizedBox(
              height: 50,
            ),
            SelectableCalendarPush()
          ],
        ),
      ),
    );
  }
}
