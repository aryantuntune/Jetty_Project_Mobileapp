class Booking {
  final int id;
  final int customerId;
  final int? ferryId;
  final int fromBranchId;
  final int toBranchId;
  final String? bookingDate;
  final String? departureTime;
  final double totalAmount;
  final String status;
  final String? qrCode;
  final String? paymentId;
  final dynamic items; // Can be JSON string or List
  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.customerId,
    this.ferryId,
    required this.fromBranchId,
    required this.toBranchId,
    this.bookingDate,
    this.departureTime,
    required this.totalAmount,
    required this.status,
    this.qrCode,
    this.paymentId,
    this.items,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: _parseInt(json['id']),
      customerId: _parseInt(json['customer_id']),
      ferryId: json['ferry_id'] != null ? _parseInt(json['ferry_id']) : null,
      fromBranchId: _parseInt(json['from_branch_id'] ?? json['from_branch']),
      toBranchId: _parseInt(json['to_branch_id'] ?? json['to_branch']),
      bookingDate: json['booking_date']?.toString(),
      departureTime: json['departure_time']?.toString(),
      totalAmount: _parseDouble(json['total_amount']),
      status: json['status']?.toString() ?? 'pending',
      qrCode: json['qr_code']?.toString(),
      paymentId: json['payment_id']?.toString(),
      items: json['items'],
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'ferry_id': ferryId,
      'from_branch_id': fromBranchId,
      'to_branch_id': toBranchId,
      'booking_date': bookingDate,
      'departure_time': departureTime,
      'total_amount': totalAmount,
      'status': status,
      'qr_code': qrCode,
      'payment_id': paymentId,
      'items': items,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isActive => status == 'confirmed' || status == 'pending' || status == 'success' || status == 'paid';
  bool get isCancelled => status == 'cancelled';
  bool get isPaid => status == 'paid' || status == 'success';

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
  String toString() => 'Booking(id: $id, status: $status, amount: $totalAmount)';
}
