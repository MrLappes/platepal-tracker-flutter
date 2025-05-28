/// User ingredient model for chat context
class UserIngredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String? barcode;
  final DateTime? scannedAt;
  final Map<String, dynamic>? metadata;

  const UserIngredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.barcode,
    this.scannedAt,
    this.metadata,
  });

  factory UserIngredient.fromJson(Map<String, dynamic> json) {
    return UserIngredient(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      barcode: json['barcode'] as String?,
      scannedAt:
          json['scannedAt'] != null
              ? DateTime.parse(json['scannedAt'] as String)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'barcode': barcode,
      'scannedAt': scannedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  UserIngredient copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? barcode,
    DateTime? scannedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      scannedAt: scannedAt ?? this.scannedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
