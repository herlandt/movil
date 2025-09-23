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