import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewDailyReport extends StatefulWidget {
  final DateTime date;
  const ViewDailyReport({required this.date, super.key});

  @override
  State<ViewDailyReport> createState() => _ViewDailyReportState();
}

class _ViewDailyReportState extends State<ViewDailyReport> {
  late String date;
  int index = 0;
  bool _isLoading = true;
  String loadingText = 'Loading';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    date = DateFormat('dd/MM/yy').format(widget.date);
    _startLoadingAnimation();
    // Timer.periodic(Duration(seconds: 8), (timerName) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
  }

  void _startLoadingAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!_isLoading) {
        _timer?.cancel();
        return;
      }

      setState(() {
        switch (index) {
          case 0:
            loadingText = 'Loading';
            break;
          case 1:
            loadingText = 'Loading.';
            break;
          case 2:
            loadingText = 'Loading..';
            break;
          case 3:
            loadingText = 'Loading...';
            break;
        }
        index = (index + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(date,
            style: theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onSurface,
            )),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Center(
                    child: Text(
                        '     $loadingText\nPlease wait for\nData Graphics',
                        style: theme.textTheme.headlineLarge!.copyWith(
                          color: theme.colorScheme.onSurface,
                        )),
                  ),
                  ElevatedButton(
                      onPressed: () => setState(() {
                            _isLoading = false;
                          }),
                      child: Text("end loading"))
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Text('done loading ill show data graphics here',
                        style: theme.textTheme.headlineLarge!.copyWith(
                          color: theme.colorScheme.onSurface,
                        )),
                  ),
                ],
              ),
      ),
    );
  }
}
