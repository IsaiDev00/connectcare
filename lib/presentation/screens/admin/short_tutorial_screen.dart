import 'package:connectcare/presentation/screens/general/dynamic_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortTutorialScreen extends StatefulWidget {
  const ShortTutorialScreen({super.key});

  @override
  _ShortTutorialScreen createState() => _ShortTutorialScreen();
}

class _ShortTutorialScreen extends State<ShortTutorialScreen> {
  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        title: Text("Short Tutorial".tr()),
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
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "Excellent, now I am going to briefly explain how to add more functionalities to your hospital.".tr(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "First of all, you must add the areas that your hospital has, such as Anesthesiology, Pediatrics, etc.".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Then you must add the rooms that your areas have, such as the operating room or emergency room, \nyou can also add a room number in case you have several for the same purpose.\nHere you must add the number of beds that said room has.".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Remember that you can also specify the services of each area and the procedures of each room in your home page.".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "You can also administer the medications that your hospital handles.".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "You can manage the information of your workers and even generate predictions of the demand for rooms, \nmedications and an estimated number of patients per condition.".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Thank you for using ConnectCare".tr(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DynamicWrapper(),
                        ),
                      );
                    },
                    child: Text("Got it".tr()),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
