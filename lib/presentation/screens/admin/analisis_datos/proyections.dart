// proyections.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'services.dart';
import 'models.dart';
import 'dart:async';

class AnimatedLoadingText extends StatefulWidget {
  final String text;
  const AnimatedLoadingText({Key? key, required this.text}) : super(key: key);

  @override
  _AnimatedLoadingTextState createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<AnimatedLoadingText> {
  int dotCount = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * dotCount;
    return Text(
      '${widget.text}$dots',
      style: const TextStyle(fontSize: 20),
    );
  }
}

class Proyections extends StatefulWidget {
  const Proyections({Key? key}) : super(key: key);

  @override
  _ProyectionsState createState() => _ProyectionsState();
}

class _ProyectionsState extends State<Proyections> {
  final ApiService apiService = ApiService(
      baseUrl: 'https://analisis-320080170162.us-central1.run.app/projections');

  String? selectedOption; // Opción elegida (arima, proyeccion_salas, etc.)
  int? secondParam; // Almacenará el número entero (m_a o b_s)
  bool isLoading = false;
  String? errorMessage;

  List<Projection> projections = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proyecciones ARIMA'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: selectedOption,
              isExpanded: true,
              hint: Text(
                'Seleccione una opción'.tr(),
                style: TextStyle(fontSize: 16),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue;
                  secondParam = null; // Reiniciar el segundo parámetro
                  projections.clear(); // Limpiar proyecciones
                  errorMessage = null; // Limpiar error
                });
              },
              items: <String>[
                'arima',
                'proyeccion_salas',
                'proyeccion_pacientes_padecimientos',
                'proyeccion_tiempo_reposo',
              ].map<DropdownMenuItem<String>>((String value) {
                String displayText;
                switch (value) {
                  case 'arima':
                    displayText = 'Uso de Medicamentos';
                    break;
                  case 'proyeccion_salas':
                    displayText = 'Uso de Salas';
                    break;
                  case 'proyeccion_pacientes_padecimientos':
                    displayText = 'Pacientes por Padecimientos';
                    break;
                  case 'proyeccion_tiempo_reposo':
                    displayText = 'Tiempo de Reposo';
                    break;
                  default:
                    displayText = value;
                }
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    displayText,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Segundo dropdown: Solo se muestra cuando hay algo seleccionado en el primero
            if (selectedOption != null) buildSecondDropdown(),

            const SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? Center(
                      child:
                          AnimatedLoadingText(text: 'Generando proyecciones'),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSecondDropdown() {
    // Si es arima / proyeccion_salas / proyeccion_pacientes_padecimientos => Elija el periodo [6,12,18,24]
    // Si es proyeccion_tiempo_reposo => "Dividir padecimientos por imagen" => [5,10,15]
    bool isTimeBased = (selectedOption == 'arima' ||
        selectedOption == 'proyeccion_salas' ||
        selectedOption == 'proyeccion_pacientes_padecimientos');

    String hintText = isTimeBased
        ? 'Elija el periodo a proyectar'
        : 'Dividir padecimientos por imagen';

    List<int> itemsList = isTimeBased ? [6, 12, 18, 24] : [5, 10, 15];

    return DropdownButton<int>(
      value: secondParam,
      isExpanded: true,
      hint: Text(
        hintText,
        style: const TextStyle(fontSize: 16),
      ),
      onChanged: (int? newValue) {
        setState(() {
          secondParam = newValue;
        });
        // Llamar a fetchProjection una vez se elija la segunda opción
        if (secondParam != null) {
          fetchProjection();
        }
      },
      items: itemsList.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(
            value.toString(),
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  Widget buildContent() {
    if (projections.isEmpty) {
      return Center(child: Text('No hay proyecciones disponibles.').tr());
    }

    return ListView.builder(
      itemCount: projections.length,
      itemBuilder: (context, index) {
        final projection = projections[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  projection.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenImage(imageUrl: projection.imageUrl),
                      ),
                    );
                  },
                  child: Hero(
                    tag: projection.imageUrl,
                    child: Image.network(
                      projection.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'Error al cargar la imagen'.tr(),
                          style: TextStyle(fontSize: 14),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void fetchProjection() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      projections = [];
    });

    try {
      Map<String, dynamic> params = {};
      final endpoint = selectedOption!;

      // Decidir si es m_a o b_s
      if (endpoint == 'arima' ||
          endpoint == 'proyeccion_salas' ||
          endpoint == 'proyeccion_pacientes_padecimientos') {
        params['m_a'] = secondParam; // months_ahead
      } else if (endpoint == 'proyeccion_tiempo_reposo') {
        params['b_s'] = secondParam; // batch_size
      }

      projections = await apiService.fetchProjections(endpoint, params);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1,
            maxScale: 4,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  'Error al cargar la imagen'.tr(),
                  style: TextStyle(color: Colors.white, fontSize: 14),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
