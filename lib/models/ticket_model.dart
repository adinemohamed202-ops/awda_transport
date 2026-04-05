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

  // 🔥 بيانات الأدمن (الناقصة)
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

    // 🔥 الجديد
    this.code,
    this.userId,
    this.message,
    this.receiptImage,

    this.createdAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id']?.toString(),
      type: json['type']?.toString() ?? 'unknown',

      isRead: json['is_read'] == true || json['is_read'] == 1,

      from: json['from']?.toString(),
      to: json['to']?.toString(),
      companyName: json['company_name']?.toString(),
      supervisorName: json['supervisor_name']?.toString(),
      supervisorPhone: json['supervisor_phone']?.toString(),
      passengerName: json['passenger_name']?.toString(),
      passengerPhone: json['passenger_phone']?.toString(),

      seats: json['seats'] != null
          ? _parseSeats(json['seats'])
          : null,

      totalPrice: _toInt(json['total_price']),
      tripDate: json['trip_date']?.toString(),
      ticketNumber: json['ticket_number']?.toString(),
      status: json['status']?.toString() ?? 'pending',

      amount: _toInt(json['amount']),
      walletId: json['wallet_id']?.toString(),

      // 🔥 الجديد (مهم جداً)
      code: json['code']?.toString(),
      userId: json['user_id']?.toString(),
      message: json['message']?.toString(),
      receiptImage: json['receipt_image']?.toString(),

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
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

  Map<String, dynamic> toJson() {
    return {
      "id": id,
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

      // 🔥 الجديد
      "code": code,
      "user_id": userId,
      "message": message,
      "receipt_image": receiptImage,

      "created_at": createdAt?.toIso8601String(),
    };
  }

  String get createdAtFormatted {
    if (createdAt == null) return "-";
    final d = createdAt!;
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
        "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }
}