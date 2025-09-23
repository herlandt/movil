// movil/lib/screens/historial_pagos_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Modelo para representar un Pago
class Pago {
  final int id;
  final String montoPagado;
  final String fechaPago;
  final String comprobante;

  Pago({
    required this.id,
    required this.montoPagado,
    required this.fechaPago,
    required this.comprobante,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'],
      montoPagado: json['monto_pagado'],
      fechaPago: json['fecha_pago'],
      comprobante: json['comprobante'] ?? 'N/A',
    );
  }
}

class HistorialPagosScreen extends StatefulWidget {
  const HistorialPagosScreen({Key? key}) : super(key: key);

  @override
  _HistorialPagosScreenState createState() => _HistorialPagosScreenState();
}

class _HistorialPagosScreenState extends State<HistorialPagosScreen> {
  late Future<List<Pago>> futurePagos;

  @override
  void initState() {
    super.initState();
    futurePagos = _obtenerHistorialPagos();
  }

  Future<List<Pago>> _obtenerHistorialPagos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) throw Exception('Token no encontrado.');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/finanzas/pagos/'),
      headers: <String, String>{'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Pago.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar el historial de pagos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Pagos'),
      ),
      body: FutureBuilder<List<Pago>>(
        future: futurePagos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pago = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.receipt_long, color: Colors.greenAccent),
                    title: Text('Monto Pagado: \$${pago.montoPagado}'),
                    subtitle: Text('Fecha: ${pago.fechaPago}\nComprobante: ${pago.comprobante}'),
                    isThreeLine: true,
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No has realizado ningún pago.'));
          }
        },
      ),
    );
  }
}