class SolicitudMantenimiento {
  final String titulo;
  final String descripcion;
  final String estado;

  SolicitudMantenimiento({required this.titulo, required this.descripcion, required this.estado});

  factory SolicitudMantenimiento.fromJson(Map<String, dynamic> json) {
    return SolicitudMantenimiento(
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      estado: json['estado'],
    );
  }
}