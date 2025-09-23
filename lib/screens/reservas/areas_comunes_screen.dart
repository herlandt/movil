// movil/lib/screens/areas_comunes_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'nueva_reserva_screen.dart';

// Modelo para AreaComun (actualizado con los nuevos campos)
class AreaComun {
  final int id;
  final String nombre;
  final String descripcion;
  final String costoReserva;
  final String? horarioApertura;
  final String? horarioCierre;

  AreaComun({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.costoReserva,
    this.horarioApertura,
    this.horarioCierre,
  });

  factory AreaComun.fromJson(Map<String, dynamic> json) {
    return AreaComun(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      costoReserva: json['costo_reserva'],
      horarioApertura: json['horario_apertura'],
      horarioCierre: json['horario_cierre'],
    );
  }
}

class AreasComunesScreen extends StatefulWidget {
  const AreasComunesScreen({Key? key}) : super(key: key);

  @override
  _AreasComunesScreenState createState() => _AreasComunesScreenState();
}

class _AreasComunesScreenState extends State<AreasComunesScreen> {
  late Future<List<AreaComun>> futureAreas;

  @override
  void initState() {
    super.initState();
    futureAreas = _obtenerAreasComunes();
  }

  Future<List<AreaComun>> _obtenerAreasComunes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/condominio/areas-comunes/'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => AreaComun.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar las áreas comunes.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar Área Común'),
      ),
      body: FutureBuilder<List<AreaComun>>(
        future: futureAreas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final area = snapshot.data![index];
                String horario = (area.horarioApertura != null && area.horarioCierre != null)
                    ? 'Horario: ${area.horarioApertura} - ${area.horarioCierre}'
                    : 'Horario no especificado';
                
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(area.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${area.descripcion}\n$horario'),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('\$${area.costoReserva}', style: TextStyle(fontSize: 16, color: Colors.greenAccent)),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NuevaReservaScreen(areaComun: area),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No hay áreas comunes disponibles.'));
          }
        },
      ),
    );
  }
}