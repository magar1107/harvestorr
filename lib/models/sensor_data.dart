class SensorData {
  final double ptoRpm;
  final double tankLevelPct;
  final double suctionPressure;
  final int baleCount;
  final double? moisturePct;
  final int ts;

  SensorData({
    required this.ptoRpm,
    required this.tankLevelPct,
    required this.suctionPressure,
    required this.baleCount,
    required this.ts,
    this.moisturePct,
  });

  factory SensorData.fromMap(Map data) {
    double _d(v) => (v is num) ? v.toDouble() : 0.0;
    int _i(v) => (v is num) ? v.toInt() : 0;
    return SensorData(
      ptoRpm: _d(data['ptoRpm']),
      tankLevelPct: _d(data['tankLevelPct']),
      suctionPressure: _d(data['suctionPressure']),
      baleCount: _i(data['baleCount']),
      moisturePct: data['moisturePct'] is num ? (data['moisturePct'] as num).toDouble() : null,
      ts: _i(data['ts']),
    );
  }
}
