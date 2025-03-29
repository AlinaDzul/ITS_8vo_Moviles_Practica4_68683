import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String _apiUrl = dotenv.get('API_URL');

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al registrarse: ${response.body}');
    }
  }

  static Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      await _saveToken(token);
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getTasks() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_apiUrl/tareas'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar las tareas: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> task) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_apiUrl/tareas'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(task),
    );
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear la tarea: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateTask(int id, Map<String, dynamic> task) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(task),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> toggleTaskCompletion(int id, bool completed) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'completada': completed}),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea: ${response.body}');
    }
  }

  static Future<void> deleteTask(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la tarea: ${response.body}');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}