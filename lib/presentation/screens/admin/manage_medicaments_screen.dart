import 'package:flutter/material.dart';

class ManageMedications extends StatefulWidget {
  const ManageMedications({super.key});

  @override
  State<ManageMedications> createState() => _ManageMedicationsState();
}

class _ManageMedicationsState extends State<ManageMedications> {
  List<String> medicaments = ['Paracetamol local', 'Ibuprofeno local'];
  List<String> filterMedicaments = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filterMedicaments = medicaments;
  }

  void updateFilter(String query) {
    setState(() {
      filterMedicaments = medicaments
          .where((medicament) =>
              medicament.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Medicamentos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              SizedBox(
                width: 400,
                child: TextFormField(
                  controller: searchController,
                  onChanged: updateFilter,
                  decoration: const InputDecoration(
                    labelText: "Search...",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for the room';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              filterMedicaments.isEmpty
                  ? const Center(
                      child: Text(
                        'Nada que ver por aquí',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: filterMedicaments.length,
                        itemBuilder: (context, index) {
                          final item = filterMedicaments[index];
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item,
                                  style: theme.textTheme.headlineLarge,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createMedicamentScreen');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Agregar medicamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
