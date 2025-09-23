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