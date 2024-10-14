import 'package:flutter/material.dart';
import 'package:connectcare/data/repositories/table/personal_repository.dart';
import 'package:connectcare/services/shared_preferences_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final PersonalRepository _personalRepository = PersonalRepository();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String userPassword = '';
  String userApellidoPaterno = '';
  String userApellidoMaterno = '';
  String userTipo = '';
  String userEstatus = '';
  String userAsignado = '';
  String userClues = '';
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userIdString = await _sharedPreferencesService.getUserId();
      if (userIdString != null) {
        userId = int.parse(userIdString);
        final userData = await _personalRepository.getById(userId!);
        if (userData != null) {
          setState(() {
            userName = userData['nombre'] ?? 'Nombre no disponible';
            userEmail =
                userData['correo_electronico'] ?? 'Correo no disponible';
            userPhone = userData['telefono'] ?? 'Teléfono no disponible';
            userPassword = userData['contrasena'] ?? '';
            userApellidoPaterno = userData['apellido_paterno'] ?? '';
            userApellidoMaterno = userData['apellido_materno'] ?? '';
            userTipo = userData['tipo'] ?? '';
            userEstatus = userData['estatus'] ?? '';
            userAsignado = userData['asignado'] ?? '';
            userClues = userData['clues'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar los datos del usuario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos del usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableField(context, 'Name', userName, false),
            const Divider(),
            _buildEditableField(context, 'Phone', userPhone, true),
            const Divider(),
            _buildEditableField(context, 'Email', userEmail, true),
            const Divider(),
            _buildEditableField(context, 'Password', '*********', true),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
      BuildContext context, String label, String value, bool isEditable) {
    return InkWell(
      onTap: isEditable
          ? () {
              _showEditDialog(context, label, value);
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                ),
              ],
            ),
            if (isEditable)
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16.0,
                  color: Colors.grey,
                ),
                onPressed: () {
                  _showEditDialog(context, label, value);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String label, String value) {
    TextEditingController controller = TextEditingController(text: value);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new $label'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Field cannot be left empty')),
                  );
                  return;
                }
                // Actualizar solo el campo editado en la base de datos
                try {
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User ID is not available')),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Updating profile...')),
                  );

                  switch (label) {
                    case 'Name':
                      userName = controller.text.trim();
                      break;
                    case 'Phone':
                      userPhone = controller.text.trim();
                      break;
                    case 'Email':
                      userEmail = controller.text.trim();
                      break;
                    case 'Password':
                      userPassword = controller.text.trim();
                      break;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sending data to update...')),
                  );

                  await _personalRepository.update(userId!, {
                    'nombre': userName,
                    'apellido_paterno': userApellidoPaterno,
                    'apellido_materno': userApellidoMaterno,
                    'tipo': userTipo,
                    'correo_electronico': userEmail,
                    'contrasena': userPassword,
                    'telefono': userPhone,
                    'estatus': userEstatus,
                    'asignado': userAsignado,
                    'clues': userClues,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile updated successfully')),
                  );

                  setState(() {});
                  Navigator.of(context).pop();
                } catch (e) {
                  debugPrint('Error al actualizar los datos del usuario: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
