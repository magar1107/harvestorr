import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class GrainTankCard extends StatelessWidget {
  final double levelPct; // 0..100
  const GrainTankCard({super.key, required this.levelPct});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grain Tank', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (levelPct.clamp(0, 100)) / 100,
              backgroundColor: Colors.grey.shade200,
              color: levelPct >= 90 ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 8),
            Text('${levelPct.toStringAsFixed(0)}% full'),
          ],
        ),
      ),
    );
  }
}

class BaleCountCard extends StatelessWidget {
  final int count;
  const BaleCountCard({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bales Produced', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('$count bales', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PtoRpmCard extends StatelessWidget {
  final double rpm;
  const PtoRpmCard({super.key, required this.rpm});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PTO RPM', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: SleekCircularSlider(
                min: 0,
                max: 1500,
                initialValue: rpm,
                appearance: CircularSliderAppearance(
                  infoProperties: InfoProperties(
                    mainLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    modifier: (d) => '${d.toStringAsFixed(0)} RPM',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuctionPressureCard extends StatelessWidget {
  final double value; // kPa
  final String state; // Normal/Low/High
  const SuctionPressureCard({super.key, required this.value, required this.state});

  Color _stateColor() {
    switch (state) {
      case 'Low':
        return Colors.yellow.shade700;
      case 'High':
        return Colors.orange;
      case 'Normal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suction Pressure', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: _stateColor(), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(state),
                const Spacer(),
                Text('${value.toStringAsFixed(1)} kPa'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
