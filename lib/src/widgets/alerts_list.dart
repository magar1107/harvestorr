import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class AlertsList extends StatelessWidget {
  const AlertsList({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceId = context.watch<AppState>().deviceId;
    final alertsRef = FirebaseDatabase.instance
        .ref('devices/$deviceId/alerts')
        .limitToLast(20);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alerts / Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: StreamBuilder(
            stream: alertsRef.onValue,
            builder: (context, snapshot) {
              final value = (snapshot.data as DatabaseEvent?)?.snapshot.value;
              final items = <Map>[];
              if (value is Map) {
                value.forEach((k, v) {
                  if (v is Map) items.add({'id': k, ...v});
                });
                items.sort((a, b) => (b['ts'] ?? 0).compareTo(a['ts'] ?? 0));
              }
              if (items.isEmpty) return const Center(child: Text('No recent alerts'));
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final a = items[i];
                  final severity = (a['severity'] ?? 'info') as String;
                  final color = _severityColor(severity);
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      border: Border.all(color: color.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(_severityIcon(severity), color: color),
                        const SizedBox(width: 8),
                        Expanded(child: Text(a['message']?.toString() ?? '')),
                        const SizedBox(width: 8),
                        Text(_timeAgo((a['ts'] ?? 0) as int)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _severityColor(String s) {
    switch (s) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _severityIcon(String s) {
    switch (s) {
      case 'critical':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _timeAgo(int ts) {
    if (ts <= 0) return '';
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
