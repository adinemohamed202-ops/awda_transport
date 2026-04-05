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

  /// 🔥 FROM API
  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      amount: int.tryParse(json['amount'].toString()) ?? 0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// 🔥 TO API
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "amount": amount,
      "date": date.toIso8601String(),
    };
  }
}