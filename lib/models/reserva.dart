import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  final String _baseUrl = 'http://10.0.2.2:8000/api/';
  String? _token;

  Future<String?> _getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('authToken');
    return _token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token $token',
    };
  }

  // --- Métodos de la API ---

  Future<List<dynamic>> getAvisos() async {
    final response = await http.get(Uri.parse('${_baseUrl}condominio/avisos/'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Fallo al cargar los avisos');
    }
  }

  Future<List<dynamic>> getGastos() async {
    final response = await http.get(Uri.parse('${_baseUrl}finanzas/gastos/'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Fallo al cargar los gastos');
    }
  }

  Future<void> pagarGasto(int gastoId) async {
    final response = await http.post(Uri.parse('${_baseUrl}finanzas/gastos/$gastoId/pagar/'), headers: await _getHeaders());
    if (response.statusCode != 200) {
      throw Exception('Fallo al registrar el pago');
    }
  }

  // ... (Puedes añadir aquí todos los demás métodos: getPagos, getAreas, crearReserva, etc.)
}