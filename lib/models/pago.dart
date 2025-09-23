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