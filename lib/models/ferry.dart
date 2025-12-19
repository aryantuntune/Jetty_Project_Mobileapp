class Ferry {
  final int id;
  final String name;
  final int capacity;
  final String? description;

  Ferry({
    required this.id,
    required this.name,
    required this.capacity,
    this.description,
  });

  factory Ferry.fromJson(Map<String, dynamic> json) {
    return Ferry(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      capacity: _parseInt(json['capacity']),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'description': description,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  String toString() => 'Ferry(id: $id, name: $name, capacity: $capacity)';
}
