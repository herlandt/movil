// movil/lib/screens/nueva_reserva_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'areas_comunes_screen.dart'; // Importamos el modelo AreaComun

class NuevaReservaScreen extends StatefulWidget {
  final AreaComun areaComun;

  const NuevaReservaScreen({Key? key, required this.areaComun}) : super(key: key);

  @override
  _NuevaReservaScreenState createState() => _NuevaReservaScreenState();
}

class _NuevaReservaScreenState extends State<NuevaReservaScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _statusMessage = '';
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _crearReserva() async {
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      setState(() {
        _statusMessage = 'Por favor, selecciona fecha y horas.';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      setState(() {
        _statusMessage = 'Error de autenticación. Inicia sesión de nuevo.';
      });
      return;
    }

    final String fechaFormateada = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    final String horaInicioFormateada = "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}";
    final String horaFinFormateada = "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}";

    setState(() {
        _isLoading = true;
        _statusMessage = 'Enviando reserva...';
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/finanzas/reservas/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(<String, dynamic>{
          'area_comun': widget.areaComun.id,
          'fecha_reserva': fechaFormateada,
          'hora_inicio': horaInicioFormateada,
          'hora_fin': horaFinFormateada,
        }),
      );
      
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) {
        setState(() {
            _statusMessage = '¡Reserva creada con éxito!';
            _isLoading = false;
        });
        Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context);
        });
      } else {
        // Mostramos el error específico que nos envía el backend
        String errorMessage = responseData.toString();
        if (responseData['non_field_errors'] != null) {
          errorMessage = responseData['non_field_errors'][0];
        }
        setState(() {
            _statusMessage = 'Error: $errorMessage';
            _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar ${widget.areaComun.nombre}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Mostramos las reglas del área
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Costo: \$${widget.areaComun.costoReserva}\nHorario: ${widget.areaComun.horarioApertura ?? 'N/A'} - ${widget.areaComun.horarioCierre ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Selector de Fecha
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(_selectedDate == null ? 'Seleccionar fecha' : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
              onTap: () => _selectDate(context),
            ),
            // Selector de Hora de Inicio
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text(_startTime == null ? 'Seleccionar hora de inicio' : _startTime!.format(context)),
              onTap: () => _selectTime(context, true),
            ),
            // Selector de Hora de Fin
            ListTile(
              leading: Icon(Icons.access_time_filled),
              title: Text(_endTime == null ? 'Seleccionar hora de fin' : _endTime!.format(context)),
              onTap: () => _selectTime(context, false),
            ),
            SizedBox(height: 30),
            
            _isLoading 
              ? Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _crearReserva,
                  child: Text('Confirmar Reserva'),
                ),
            
            SizedBox(height: 20),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: _isLoading ? Colors.white : Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}