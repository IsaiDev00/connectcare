import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/data/services/shared_preferences_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  bool _isLoading = true;
  // ignore: unused_field
  bool _isUpdating = false;

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

        // Llamada al endpoint unificado
        final url = Uri.parse('$baseUrl/auth/user_by_id/$userId');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);

          setState(() {
            userName = userData['nombre'] ?? 'Nombre no disponible';
            userEmail =
                userData['correo_electronico'] ?? 'Correo no disponible';
            userPhone = userData['telefono'] ?? 'Teléfono no disponible';
            userPassword = userData['contrasena'] ?? '';
            userApellidoPaterno = userData['apellido_paterno'] ?? '';
            userApellidoMaterno = userData['apellido_materno'] ?? '';
            userTipo = userData['tipo'] ?? '';

            // Si el usuario pertenece a "personal", carga campos adicionales
            if (userData['clues'] != null) {
              userClues = userData['clues'];
              userEstatus = userData['estatus'] ?? '';
              userAsignado = userData['asignado'] ?? '';
            }
          });
        } else {
          throw Exception('No se pudo cargar la información del usuario.');
        }
      }
    } catch (e) {
      debugPrint('Error al cargar los datos del usuario: $e');
      _userErrorResponse(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16.0),
                  _buildEditableCard(
                      'Name',
                      "$userName $userApellidoPaterno $userApellidoMaterno",
                      false),
                  _buildEditableCard('Phone', userPhone, true),
                  _buildEditableCard('Email', userEmail, true),
                  _buildEditableCard('Password', userPassword, true),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            "$userName $userApellidoPaterno $userApellidoMaterno",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8.0),
          Text(
            userTipo.isNotEmpty ? userTipo : "Tipo no disponible",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard(String label, String value, bool isEditable) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: isEditable
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  _showEditDialog(context, label, value);
                },
              )
            : null,
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
                await _updateProfileField(label, controller.text.trim());
                _navigator();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfileField(String label, String newValue) async {
    if (newValue.isEmpty) {
      showCustomSnackBar(context, '$label cannot be empty');
      return;
    }

    try {
      setState(() {
        _isUpdating = true;
      });

      final Map<String, dynamic> updatedField = {
        if (label == 'Phone') 'telefono': newValue,
        if (label == 'Email') 'correo_electronico': newValue,
        if (label == 'Password') 'contrasena': newValue,
      };

      final url = Uri.parse('$baseUrl/personal/$userId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedField),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (label == 'Phone') userPhone = newValue;
          if (label == 'Email') userEmail = newValue;
          if (label == 'Password') userPassword = newValue;
        });
        if (mounted) {
          showCustomSnackBar(context, '$label updated successfully');
        }
      } else {
        throw Exception('Failed to update $label');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Error updating $label: $e');
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _userErrorResponse(e) {
    showCustomSnackBar(context, 'Error al cargar los datos del usuario: $e');
  }

  void _navigator() {
    Navigator.of(context).pop();
  }
}
