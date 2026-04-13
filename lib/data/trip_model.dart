import 'package:flutter/foundation.dart';

@immutable
class TripModel {
  final String? tripCode;
  final String? type;
  final String? companyCode;
  final DateTime? createdAt;
  final DateTime? tripDate;
  final String? from;
  final String? to;

  const TripModel({
    this.tripCode,
    this.type,
    this.companyCode,
    this.createdAt,
    this.tripDate,
    this.from,
    this.to,
  });

  /// 🔥 نسخة احترافية copyWith لتحديث القيم
  TripModel copyWith({
    String? tripCode,
    String? type,
    String? companyCode,
    DateTime? createdAt,
    DateTime? tripDate,
    String? from,
    String? to,
  }) {
    return TripModel(
      tripCode: tripCode ?? this.tripCode,
      type: type ?? this.type,
      companyCode: companyCode ?? this.companyCode,
      createdAt: createdAt ?? this.createdAt,
      tripDate: tripDate ?? this.tripDate,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}