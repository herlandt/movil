// movil/lib/screens/finanzas_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'historial_pagos_screen.dart'; // <-- 1. IMPORTA LA NUEVA PANTALLA

// ... (Clase Gasto y resto del código existente) ...
class Gasto {
  final int id;
  final String monto;
  final String fechaVencimiento;
  final String descripcion;
  final bool pagado;

  Gasto({
    required this.id,
    required this.monto,
    required this.fechaVencimiento,
    required this.descripcion,
    required this.pagado,
  });

  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'],
      monto: json['monto'],
      fechaVencimiento: json['fecha_vencimiento'],
      descripcion: json['descripcion'],
      pagado: json['pagado'],
    );
  }
}

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({Key? key}) : super(key: key);

  @override
  _FinanzasScreenState createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  late Future<List<Gasto>> futureGastos;

  @override
  void initState() {
    super.initState();
    futureGastos = _obtenerGastos();
  }

  Future<List<Gasto>> _obtenerGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('Token no encontrado.');
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/finanzas/gastos/'),
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Gasto.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar el estado de cuenta.');
    }
  }

  Future<void> _pagarGasto(int gastoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de autenticación.'))
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/finanzas/gastos/$gastoId/pagar/'),
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago registrado con éxito!'), backgroundColor: Colors.green)
      );
      // Refrescar la lista de gastos para mostrar el cambio
      setState(() {
        futureGastos = _obtenerGastos();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el pago.'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Estado de Cuenta'),
      ),
      body: FutureBuilder<List<Gasto>>(
        future: futureGastos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final gasto = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: gasto.pagado ? Colors.green.shade900 : Colors.red.shade900,
                  child: ListTile(
                    title: Text(gasto.descripcion, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Vence: ${gasto.fechaVencimiento}'),
                    trailing: gasto.pagado
                      ? Icon(Icons.check_circle, color: Colors.white)
                      : ElevatedButton(
                          onPressed: () => _pagarGasto(gasto.id),
                          child: Text('Pagar'),
                        ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No tienes gastos registrados.'));
          }
        },
      ),
      // VVV 2. AÑADE ESTE BOTÓN VVV
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistorialPagosScreen()),
          );
        },
        child: Icon(Icons.history),
        tooltip: 'Ver Historial de Pagos',
      ),
    );
  }
}