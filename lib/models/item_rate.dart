class ItemRate {
  final int id;
  final String itemName;
  final double price;
  final String? description;

  ItemRate({
    required this.id,
    required this.itemName,
    required this.price,
    this.description,
  });

  factory ItemRate.fromJson(Map<String, dynamic> json) {
    return ItemRate(
      id: _parseInt(json['id']),
      itemName: json['item_name']?.toString() ?? '',
      price: _parseDouble(json['price']),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'price': price,
      'description': description,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  String toString() => 'ItemRate(id: $id, itemName: $itemName, price: $price)';
}
