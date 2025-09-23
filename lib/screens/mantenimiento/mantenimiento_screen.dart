// movil/lib/screens/mantenimiento_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'nueva_solicitud_screen.dart'; // Importamos la pantalla del formulario

// Modelo para representar una Solicitud
class Solicitud {
  final String titulo;
  final String descripcion;
  final String estado;

  Solicitud({required this.titulo, required this.descripcion, required this.estado});

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      estado: json['estado'],
    );
  }
}

class MantenimientoScreen extends StatefulWidget {
  const MantenimientoScreen({Key? key}) : super(key: key);

  @override
  _MantenimientoScreenState createState() => _MantenimientoScreenState();
}

class _MantenimientoScreenState extends State<MantenimientoScreen> {
  late Future<List<Solicitud>> futureSolicitudes;

  @override
  void initState() {
    super.initState();
    futureSolicitudes = _obtenerSolicitudes();
  }

  Future<List<Solicitud>> _obtenerSolicitudes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) throw Exception('Token no encontrado.');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/solicitudes-mantenimiento/'),
      headers: <String, String>{'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Solicitud.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar las solicitudes.');
    }
  }

  // Función para refrescar la lista
  void _refrescarSolicitudes() {
    setState(() {
      futureSolicitudes = _obtenerSolicitudes();
    });
  }

  // Función para obtener un color basado en el estado
  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en_progreso':
        return Colors.blue;
      case 'completado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mantenimiento'),
      ),
      body: FutureBuilder<List<Solicitud>>(
        future: futureSolicitudes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final solicitud = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.build),
                    title: Text(solicitud.titulo),
                    subtitle: Text(solicitud.descripcion),
                    trailing: Chip(
                      label: Text(solicitud.estado, style: TextStyle(color: Colors.white)),
                      backgroundColor: _getColorForEstado(solicitud.estado),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No tienes solicitudes registradas.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NuevaSolicitudScreen()),
          );
          if (resultado == 'creado') {
            _refrescarSolicitudes();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Nueva Solicitud',
      ),
    );
  }
}