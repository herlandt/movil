// movil/lib/screens/nueva_visita_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NuevaVisitaScreen extends StatefulWidget {
  const NuevaVisitaScreen({Key? key}) : super(key: key);

  @override
  _NuevaVisitaScreenState createState() => _NuevaVisitaScreenState();
}

class _NuevaVisitaScreenState extends State<NuevaVisitaScreen> {
  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  DateTime? _fechaIngreso;
  TimeOfDay? _horaIngreso;
  String _statusMessage = '';

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _fechaIngreso = date;
      _horaIngreso = time;
    });
  }

  Future<void> _registrarVisita() async {
    if (_nombreController.text.isEmpty || _documentoController.text.isEmpty || _fechaIngreso == null || _horaIngreso == null) {
      setState(() {
        _statusMessage = 'Por favor, completa todos los campos.';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      setState(() { _statusMessage = 'Error de autenticación.'; });
      return;
    }
    
    // Asumimos que la visita es por 3 horas, puedes cambiar esta lógica
    final DateTime ingresoDateTime = DateTime(_fechaIngreso!.year, _fechaIngreso!.month, _fechaIngreso!.day, _horaIngreso!.hour, _horaIngreso!.minute);
    final DateTime salidaDateTime = ingresoDateTime.add(const Duration(hours: 3));

    setState(() { _statusMessage = 'Registrando visita...'; });

    try {
      final response = await http.post(
       Uri.parse('http://10.0.2.2:8000/api/mantenimiento/solicitudes/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'visitante': {
            'nombre_completo': _nombreController.text,
            'documento_identidad': _documentoController.text,
          },
          'fecha_ingreso_programado': ingresoDateTime.toIso8601String(),
          'fecha_salida_programada': salidaDateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        setState(() { _statusMessage = '¡Visita registrada con éxito!'; });
        // Espera un momento y regresa a la pantalla anterior con un resultado
        Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context, 'creado');
        });
      } else {
        setState(() { _statusMessage = 'Error: ${response.body}'; });
      }
    } catch (e) {
      setState(() { _statusMessage = 'Error de conexión: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nueva Visita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text("Datos del Visitante", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre Completo del Visitante'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _documentoController,
              decoration: const InputDecoration(labelText: 'Documento de Identidad'),
            ),
            const SizedBox(height: 24),
            Text("Fecha y Hora de Ingreso", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_fechaIngreso == null 
                  ? 'Seleccionar fecha y hora' 
                  : 'Fecha: ${_fechaIngreso!.day}/${_fechaIngreso!.month}/${_fechaIngreso!.year} - Hora: ${_horaIngreso!.format(context)}'),
              onTap: () => _selectDateTime(context),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _registrarVisita,
              child: const Text('Registrar Visita'),
            ),
            const SizedBox(height: 20),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}