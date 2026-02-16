class WaterRecord {
  final DateTime timestamp;
  final int amountMl;

  const WaterRecord({required this.timestamp, required this.amountMl});

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'amountMl': amountMl,
      };

  factory WaterRecord.fromJson(Map<String, dynamic> json) => WaterRecord(
        timestamp: DateTime.parse(json['timestamp'] as String),
        amountMl: json['amountMl'] as int,
      );
}
