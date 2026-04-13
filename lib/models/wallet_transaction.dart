class WalletTransaction {
  final String? id;
  final String title;
  final int amount;
  final DateTime date;

  WalletTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  /// 🔥 FROM API (محسن وقوي)
  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id']?.toString(),

      // في حالة السيرفر رجع null أو اسم مختلف
      title: (json['title'] ??
              json['name'] ??
              json['description'] ??
              '')
          .toString(),

      // يدعم int / double / string
      amount: _parseAmount(json['amount']),

      // يدعم formats مختلفة للتاريخ
      date: _parseDate(json['date']),
    );
  }

  /// 🔥 TO API
  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      "title": title,
      "amount": amount,
      "date": date.toIso8601String(),
    };
  }

  /// 🔧 Helper: تحويل amount بأمان
  static int _parseAmount(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is String) {
      return int.tryParse(value) ??
          double.tryParse(value)?.toInt() ??
          0;
    }

    return 0;
  }

  /// 🔧 Helper: تحويل التاريخ بأمان
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  /// 🔥 اختياري: نسخ مع تعديل
  WalletTransaction copyWith({
    String? id,
    String? title,
    int? amount,
    DateTime? date,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}