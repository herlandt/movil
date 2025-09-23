// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importaciones corregidas a la nueva estructura
import '../reservas/areas_comunes_screen.dart';
import '../finanzas/finanzas_screen.dart';
import '../visitas/visitas_screen.dart';
import '../mantenimiento/mantenimiento_screen.dart';
import '../../models/aviso.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  // Advertencia 1 corregida aquí:
  const HomeScreen({super.key, required this.onLogout});

  @override
  // Advertencia 2 corregida aquí:
  HomeScreenState createState() => HomeScreenState();
}

// Y aquí:
class HomeScreenState extends State<HomeScreen> {
  late Future<List<Aviso>> futureAvisos;

  @override
  void initState() {
    super.initState();
    futureAvisos = _obtenerAvisos();
  }

  Future<List<Aviso>> _obtenerAvisos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) throw Exception('Token no encontrado.');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/condominio/avisos/'),
      headers: <String, String>{'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Aviso.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar los avisos.');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avisos del Condominio'),
        actions: [
          IconButton(
            icon: Icon(Icons.build),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MantenimientoScreen()));
            },
            tooltip: 'Mantenimiento',
          ),
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VisitasScreen()));
            },
            tooltip: 'Gestionar Visitas',
          ),
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanzasScreen()));
            },
            tooltip: 'Estado de Cuenta',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: FutureBuilder<List<Aviso>>(
        future: futureAvisos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final aviso = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text(aviso.titulo),
                    subtitle: Text(aviso.contenido),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No hay avisos para mostrar.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AreasComunesScreen()));
        },
        icon: Icon(Icons.calendar_today),
        label: Text("Reservar"),
      ),
    );
  }
}