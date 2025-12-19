class Branch {
  final int id;
  final String name;

  Branch({
    required this.id,
    required this.name,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: _parseInt(json['id']),
      // Server returns 'name' from getBranches() and 'branch_name' from getToBranches()
      name: json['name']?.toString() ?? json['branch_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  String toString() => 'Branch(id: $id, name: $name)';
}
