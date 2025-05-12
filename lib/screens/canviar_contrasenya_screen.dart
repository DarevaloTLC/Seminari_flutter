import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/users_provider.dart';
import '../services/UserService.dart';

class CanviarContrasenyaScreen extends StatefulWidget {
  const CanviarContrasenyaScreen({super.key});

  @override
  State<CanviarContrasenyaScreen> createState() => _CanviarContrasenyaScreenState();
}

class _CanviarContrasenyaScreenState extends State<CanviarContrasenyaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actualController = TextEditingController();
  final _novaController = TextEditingController();
  final _confirmacioController = TextEditingController();

  @override
  void dispose() {
    _actualController.dispose();
    _novaController.dispose();
    _confirmacioController.dispose();
    super.dispose();
  }

  Future<void> _canviarContrasenya() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<UserProvider>().currentUser;
    if (user == null || user.id == null) return;

    try {
      // Aquí se asume que el backend requiere la contraseña actual para verificar
      final updatedUser = user.copyWith(password: _novaController.text);

      await UserService.updateUser(user.id!, updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contrasenya actualitzada correctament')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al canviar la contrasenya: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canviar Contrasenya')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _actualController,
                decoration: const InputDecoration(labelText: 'Contrasenya actual'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Obligatori' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _novaController,
                decoration: const InputDecoration(labelText: 'Nova contrasenya'),
                obscureText: true,
                validator: (value) =>
                    value != null && value.length >= 6
                        ? null
                        : 'Minim 6 caràcters',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmacioController,
                decoration: const InputDecoration(labelText: 'Confirmació'),
                obscureText: true,
                validator: (value) =>
                    value == _novaController.text ? null : 'No coincideix',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _canviarContrasenya,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
