// movil/lib/screens/nueva_solicitud_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NuevaSolicitudScreen extends StatefulWidget {
  const NuevaSolicitudScreen({Key? key}) : super(key: key);

  @override
  _NuevaSolicitudScreenState createState() => _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState extends State<NuevaSolicitudScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _statusMessage = '';

  Future<void> _enviarSolicitud() async {
    if (_tituloController.text.isEmpty || _descripcionController.text.isEmpty) {
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
    
    setState(() { _statusMessage = 'Enviando solicitud...'; });

    try {
      final response = await http.post(
       Uri.parse('http://10.0.2.2:8000/api/mantenimiento/solicitudes/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(<String, String>{
          'titulo': _tituloController.text,
          'descripcion': _descripcionController.text,
        }),
      );

      if (response.statusCode == 201) { // 201 Created
        setState(() { _statusMessage = '¡Solicitud enviada con éxito!'; });
        Future.delayed(const Duration(seconds: 1), () {
            // Regresa a la pantalla anterior e informa que se creó
            Navigator.pop(context, 'creado'); 
        });
      } else {
        setState(() { _statusMessage = 'Error al enviar: ${response.body}'; });
      }
    } catch (e) {
      setState(() { _statusMessage = 'Error de conexión: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Solicitud'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text("Reportar un Problema", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título (ej: Foco quemado pasillo B)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del Problema',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _enviarSolicitud,
              child: const Text('Enviar Solicitud'),
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