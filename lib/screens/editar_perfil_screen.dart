import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/users_provider.dart';
import '../services/UserService.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: user?.age.toString() ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProvider>();
    final user = provider.currentUser;

    if (user == null || user.id == null) return;

    try {
      final actualizado = await UserService.updateUser(
        user.id!,
        user.copyWith(
          name: _nameController.text,
          age: int.tryParse(_ageController.text),
          email: _emailController.text,
        ),
      );

      provider.setCurrentUser(actualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualitzat correctament')),
        );
        Navigator.of(context).pop(); // volver al perfil
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error actualitzant: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Edat'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final age = int.tryParse(value ?? '');
                  if (age == null || age < 0) return 'Edat no vàlida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || !value.contains('@') ? 'Email invàlid' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarCambios,
                child: const Text('Guardar canvis'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
