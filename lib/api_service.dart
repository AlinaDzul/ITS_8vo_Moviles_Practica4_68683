import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String _apiUrl = dotenv.get('API_URL');
  static String token = ''; // Almacenar el token JWT

  // Registrar un usuario
  static Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode != 201) { // 201 Created es lo que devuelve el endpoint
      throw Exception('Error al registrarse: ${response.body}');
    }
  }

  // Iniciar sesión y obtener el token
  static Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      token = jsonDecode(response.body)['token']; // Guardar el token
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  // Obtener todas las tareas (protegido con token)
  static Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await http.get(
      Uri.parse('$_apiUrl/tareas'),
      headers: {
        'Authorization': 'Bearer $token', // Enviar el token
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar las tareas: ${response.body}');
    }
  }

  // Obtener una tarea por ID (protegido con token)
  static Future<Map<String, dynamic>> getTaskById(int id) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar la tarea: ${response.body}');
    }
  }

  // Crear una nueva tarea (protegido con token)
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> task) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/tareas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(task),
    );
    if (response.statusCode == 201) { // 201 Created para nuevas tareas
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear la tarea: ${response.body}');
    }
  }

  // Actualizar una tarea (protegido con token)
  static Future<Map<String, dynamic>> updateTask(int id, Map<String, dynamic> task) async {
    final response = await http.put( // Cambiado a PUT para coincidir con la API
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(task),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea: ${response.body}');
    }
  }

  // Marcar una tarea como completada (protegido con token)
  static Future<Map<String, dynamic>> toggleTaskCompletion(int id, bool completed) async {
    final response = await http.put( // Cambiado a PUT para la API actual
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'completada': completed}),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea: ${response.body}');
    }
  }

  // Eliminar una tarea (protegido con token)
  static Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) { // 200 OK en la API actual
      throw Exception('Error al eliminar la tarea: ${response.body}');
    }
  }
}