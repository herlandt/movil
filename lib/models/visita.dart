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