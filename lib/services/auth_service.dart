import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../provider/users_provider.dart';
import '../services/UserService.dart';
import 'package:provider/provider.dart';


class AuthService {
  bool isLoggedIn = false;

  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api/users';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:9000/api/users';
    } else {
      return 'http://localhost:9000/api/users';
    }
  }

  Future<Map<String, dynamic>> login(
      BuildContext context, String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final body = json.encode({'email': email, 'password': password});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final userId = responseData['id'];
        if (userId == null) {
          return {'error': 'Resposta del servidor sense ID d\'usuari.'};
        }

        final user = await UserService.getUserById(userId);
        context.read<UserProvider>().setCurrentUser(user);
        isLoggedIn = true;

        return {'success': true, 'user': user.toJson()};
      } else {
        return {'error': 'Email o contrasenya incorrectes'};
      }
    } catch (e) {
      return {'error': 'Error de connexió: $e'};
    }
  }

  void logout() {
    isLoggedIn = false;
    print("Sessió tancada");
  }
}
