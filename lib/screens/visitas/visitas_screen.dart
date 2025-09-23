// movil/lib/screens/visitas_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'nueva_visita_screen.dart'; // <-- Esta línea ahora funcionará

// Modelo para representar una Visita
class Visita {
  final String visitanteNombre;
  final String fechaIngreso;

  Visita({required this.visitanteNombre, required this.fechaIngreso});

  factory Visita.fromJson(Map<String, dynamic> json) {
    return Visita(
      visitanteNombre: json['visitante']['nombre_completo'],
      fechaIngreso: json['fecha_ingreso_programado'],
    );
  }
}

class VisitasScreen extends StatefulWidget {
  const VisitasScreen({Key? key}) : super(key: key);

  @override
  _VisitasScreenState createState() => _VisitasScreenState();
}

class _VisitasScreenState extends State<VisitasScreen> {
  late Future<List<Visita>> futureVisitas;

  @override
  void initState() {
    super.initState();
    futureVisitas = _obtenerVisitas();
  }

  Future<List<Visita>> _obtenerVisitas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) throw Exception('Token no encontrado.');

    final response = await http.get(
     Uri.parse('http://10.0.2.2:8000/api/seguridad/visitas/'),
      headers: <String, String>{'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Visita.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar las visitas.');
    }
  }

  // Función para refrescar la lista después de crear una nueva visita
  void _refrescarVisitas() {
    setState(() {
      futureVisitas = _obtenerVisitas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Visitas'),
      ),
      body: FutureBuilder<List<Visita>>(
        future: futureVisitas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final visita = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.person_pin_circle),
                    title: Text(visita.visitanteNombre),
                    subtitle: Text('Ingreso programado: ${visita.fechaIngreso}'),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No hay visitas programadas.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegamos a la pantalla de nueva visita y esperamos un resultado
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NuevaVisitaScreen()),
          );
          // Si el resultado es 'creado', refrescamos la lista
          if (resultado == 'creado') {
            _refrescarVisitas();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Registrar Nueva Visita',
      ),
    );
  }
}