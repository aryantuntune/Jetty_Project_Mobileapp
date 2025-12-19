class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String? profileImage;
  final DateTime? createdAt;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    this.profileImage,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: _parseInt(json['id']),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName'.trim();

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'Customer(id: $id, email: $email, name: $fullName)';
}
