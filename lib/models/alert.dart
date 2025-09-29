class AlertItem {
  final String id;
  final int ts;
  final String type; // TANK_NEAR_FULL | TANK_FULL | BALE_READY | BLOCKAGE | PTO_OVERLOAD
  final String severity; // info | warning | critical
  final String message;

  AlertItem({
    required this.id,
    required this.ts,
    required this.type,
    required this.severity,
    required this.message,
  });

  factory AlertItem.fromMap(String id, Map data) => AlertItem(
        id: id,
        ts: (data['ts'] ?? 0) is num ? (data['ts'] as num).toInt() : 0,
        type: data['type']?.toString() ?? 'info',
        severity: data['severity']?.toString() ?? 'info',
        message: data['message']?.toString() ?? '',
      );
}
