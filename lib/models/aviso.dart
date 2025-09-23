class Aviso {
  final String titulo;
  final String contenido;
  final String fechaPublicacion;

  Aviso({
    required this.titulo,
    required this.contenido,
    required this.fechaPublicacion,
  });

  factory Aviso.fromJson(Map<String, dynamic> json) {
    return Aviso(
      titulo: json['titulo'],
      contenido: json['contenido'],
      fechaPublicacion: json['fecha_publicacion'],
    );
  }
}