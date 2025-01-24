// proyections.dart
import 'package:flutter/material.dart';
import 'services.dart';
import 'models.dart';
import 'dart:async'; // Importar para usar Timer

// Widget para mostrar texto de carga animado
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
    // Inicializar el Timer para actualizar los puntos cada 500 ms
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 4; // Ciclo entre 0, 1, 2, 3
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancelar el Timer al destruir el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * dotCount; // Generar la cantidad de puntos
    return Text(
      '${widget.text}$dots',
      style: TextStyle(fontSize: 20),
    );
  }
}

class Proyections extends StatefulWidget {
  const Proyections({Key? key}) : super(key: key);

  @override
  _ProyectionsState createState() => _ProyectionsState();
}

class _ProyectionsState extends State<Proyections> {
  final ApiService apiService = ApiService(baseUrl: 'http://192.168.1.17:8080/projections');

  String? selectedOption;
  bool isLoading = false;
  String? errorMessage;

  List<Projection> projections = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proyecciones ARIMA'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Menú de selección con hint y texto reducido
            DropdownButton<String>(
              value: selectedOption,
              isExpanded: true,
              hint: Text(
                'Seleccione una opción',
                style: TextStyle(fontSize: 16),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue!;
                  fetchProjection();
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
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Área de contenido
            Expanded(
              child: isLoading
                  ? Center(
                      child: AnimatedLoadingText(text: 'Generando proyecciones'),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 16),
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

  Widget buildContent() {
    if (projections.isEmpty) {
      return Center(child: Text('No hay proyecciones disponibles.'));
    }

    return ListView.builder(
      itemCount: projections.length,
      itemBuilder: (context, index) {
        final projection = projections[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  projection.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(imageUrl: projection.imageUrl),
                      ),
                    );
                  },
                  child: Hero(
                    tag: projection.imageUrl, // Utilizar la URL como tag único
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
                        return Text('Error al cargar la imagen', style: TextStyle(fontSize: 14));
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
      String endpoint = selectedOption!;

      if (endpoint == 'arima' || endpoint == 'proyeccion_salas' || endpoint == 'proyeccion_pacientes_padecimientos') {
        params['m_a'] = 24; // months_ahead
      } else if (endpoint == 'proyeccion_tiempo_reposo') {
        params['b_s'] = 10; // batch_size
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

// Nueva Clase para Mostrar la Imagen en Pantalla Completa con Zoom
class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo negro para una mejor visualización
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fondo transparente
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: imageUrl, // Debe coincidir con el tag en el GestureDetector
          child: InteractiveViewer(
            panEnabled: true, // Permitir desplazamiento
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
                return Text('Error al cargar la imagen', style: TextStyle(color: Colors.white, fontSize: 14));
              },
            ),
          ),
        ),
      ),
    );
  }
}
