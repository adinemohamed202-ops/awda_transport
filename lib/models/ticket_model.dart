class TicketModel {
  final String? id;
  final String type;
  bool isRead;

  // 🔥 بيانات الرحلة
  final String? from;
  final String? to;
  final String? companyName;
  final String? supervisorName;
  final String? supervisorPhone;
  final String? passengerName;
  final String? passengerPhone;
  final List<int>? seats;
  final int? totalPrice;
  final String? tripDate;
  final String? ticketNumber;
  final String? status;

  // 🔥 بيانات المحفظة
  final int? amount;
  final String? walletId;

  // 🔥 بيانات الأدمن
  final String? code;
  final String? userId;
  final String? message;
  final String? receiptImage;

  final DateTime? createdAt;

  TicketModel({
    this.id,
    required this.type,
    this.isRead = false,
    this.from,
    this.to,
    this.companyName,
    this.supervisorName,
    this.supervisorPhone,
    this.passengerName,
    this.passengerPhone,
    this.seats,
    this.totalPrice,
    this.tripDate,
    this.ticketNumber,
    this.status,
    this.amount,
    this.walletId,
    this.code,
    this.userId,
    this.message,
    this.receiptImage,
    this.createdAt,
  });

  /// 🔥 FROM API (نسخة قوية جداً)
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id']?.toString(),

      type: (json['type'] ?? 'unknown').toString(),

      // يدعم true / 1 / "1"
      isRead: json['is_read'] == true ||
          json['is_read'] == 1 ||
          json['is_read']?.toString() == '1',

      from: _getString(json, ['from', 'origin']),
      to: _getString(json, ['to', 'destination']),
      companyName: _getString(json, ['company_name', 'company']),
      supervisorName: _getString(json, ['supervisor_name']),
      supervisorPhone: _getString(json, ['supervisor_phone']),
      passengerName: _getString(json, ['passenger_name']),
      passengerPhone: _getString(json, ['passenger_phone']),

      seats: json['seats'] != null ? _parseSeats(json['seats']) : null,

      totalPrice: _toInt(json['total_price']),
      tripDate: json['trip_date']?.toString(),

      ticketNumber: _getString(json, ['ticket_number', 'ticket_no']),
      status: (json['status'] ?? 'pending').toString(),

      amount: _toInt(json['amount']),
      walletId: json['wallet_id']?.toString(),

      code: json['code']?.toString(),
      userId: json['user_id']?.toString(),
      message: json['message']?.toString(),
      receiptImage: json['receipt_image']?.toString(),

      createdAt: _parseDate(json['created_at']),
    );
  }

  /// 🔥 TO API
  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      "type": type,
      "is_read": isRead,
      "from": from,
      "to": to,
      "company_name": companyName,
      "supervisor_name": supervisorName,
      "supervisor_phone": supervisorPhone,
      "passenger_name": passengerName,
      "passenger_phone": passengerPhone,
      "seats": seats,
      "total_price": totalPrice,
      "trip_date": tripDate,
      "ticket_number": ticketNumber,
      "status": status,
      "amount": amount,
      "wallet_id": walletId,
      "code": code,
      "user_id": userId,
      "message": message,
      "receipt_image": receiptImage,
      "created_at": createdAt?.toIso8601String(),
    };
  }

  /// 🔧 Helpers

  static String? _getString(Map json, List<String> keys) {
    for (var key in keys) {
      if (json[key] != null) return json[key].toString();
    }
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static List<int> _parseSeats(dynamic seats) {
    if (seats is List) {
      return seats.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }

    if (seats is String) {
      return seats
          .split(',')
          .map((e) => int.tryParse(e.trim()) ?? 0)
          .toList();
    }

    return [];
  }

  /// 🔥 مهم جداً (للـ UI)
  String get createdAtFormatted {
    if (createdAt == null) return "-";
    final d = createdAt!;
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
        "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }

  /// 🔥 copyWith (مهم جداً للـ state management)
  TicketModel copyWith({
    String? id,
    String? type,
    bool? isRead,
    String? from,
    String? to,
    String? companyName,
    String? supervisorName,
    String? supervisorPhone,
    String? passengerName,
    String? passengerPhone,
    List<int>? seats,
    int? totalPrice,
    String? tripDate,
    String? ticketNumber,
    String? status,
    int? amount,
    String? walletId,
    String? code,
    String? userId,
    String? message,
    String? receiptImage,
    DateTime? createdAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      from: from ?? this.from,
      to: to ?? this.to,
      companyName: companyName ?? this.companyName,
      supervisorName: supervisorName ?? this.supervisorName,
      supervisorPhone: supervisorPhone ?? this.supervisorPhone,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      seats: seats ?? this.seats,
      totalPrice: totalPrice ?? this.totalPrice,
      tripDate: tripDate ?? this.tripDate,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      walletId: walletId ?? this.walletId,
      code: code ?? this.code,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      receiptImage: receiptImage ?? this.receiptImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}