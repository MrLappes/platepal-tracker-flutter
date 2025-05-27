class Supplement {
  final String id;
  final String name;
  final String brand;
  final String type; // vitamin, mineral, protein, etc.
  final double servingSize;
  final String servingUnit;
  final Map<String, double> nutrients;
  final String? description;
  final String? imageUrl;
  final DateTime? expiryDate;
  final double? costPerServing;
  final String? barcode;

  const Supplement({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.servingSize,
    required this.servingUnit,
    required this.nutrients,
    this.description,
    this.imageUrl,
    this.expiryDate,
    this.costPerServing,
    this.barcode,
  });

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      type: json['type'] as String,
      servingSize: (json['servingSize'] as num).toDouble(),
      servingUnit: json['servingUnit'] as String,
      nutrients: Map<String, double>.from(json['nutrients'] as Map),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'] as String)
              : null,
      costPerServing: (json['costPerServing'] as num?)?.toDouble(),
      barcode: json['barcode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'type': type,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'nutrients': nutrients,
      'description': description,
      'imageUrl': imageUrl,
      'expiryDate': expiryDate?.toIso8601String(),
      'costPerServing': costPerServing,
      'barcode': barcode,
    };
  }

  Supplement copyWith({
    String? id,
    String? name,
    String? brand,
    String? type,
    double? servingSize,
    String? servingUnit,
    Map<String, double>? nutrients,
    String? description,
    String? imageUrl,
    DateTime? expiryDate,
    double? costPerServing,
    String? barcode,
  }) {
    return Supplement(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      nutrients: nutrients ?? this.nutrients,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      expiryDate: expiryDate ?? this.expiryDate,
      costPerServing: costPerServing ?? this.costPerServing,
      barcode: barcode ?? this.barcode,
    );
  }
}
