import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceId = context.watch<AppState>().deviceId;
    final dailyRef = FirebaseDatabase.instance.ref('aggregates/daily/$deviceId');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder(
        stream: dailyRef.onValue,
        builder: (context, snapshot) {
          final value = (snapshot.data as DatabaseEvent?)?.snapshot.value as Map? ?? {};
          final entries = value.entries.map((e) => MapEntry(e.key.toString(), (e.value as Map?) ?? {})).toList()
            ..sort((a, b) => b.key.compareTo(a.key));

          if (entries.isEmpty) {
            return const Center(child: Text('No history yet'));
          }

          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final date = entries[i].key; // YYYY-MM-DD
              final v = entries[i].value;
              final grain = (v['grainKg'] is num) ? (v['grainKg'] as num).toDouble() : 0.0;
              final bales = (v['bales'] is num) ? (v['bales'] as num).toInt() : 0;
              final runHours = (v['runHours'] is num) ? (v['runHours'] as num).toDouble() : 0.0;

              return ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(date),
                subtitle: Text('Grain: ${grain.toStringAsFixed(0)} kg   Bales: $bales   Run: ${runHours.toStringAsFixed(1)} h'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: Text('Details - $date'),
                    content: Text('Grain: ${grain.toStringAsFixed(0)} kg\nBales: $bales\nRun Hours: ${runHours.toStringAsFixed(1)}'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
