import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class GaugeWidget extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final String unit;
  const GaugeWidget({super.key, required this.value, this.min = 0, this.max = 1500, this.label = '', this.unit = ''});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          height: 140,
          child: SleekCircularSlider(
            min: min,
            max: max,
            initialValue: value.clamp(min, max),
            appearance: CircularSliderAppearance(
              size: 140,
              customColors: CustomSliderColors(progressBarColor: Colors.blue),
              infoProperties: InfoProperties(
                mainLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                modifier: (d) => unit.isNotEmpty ? '${d.toStringAsFixed(0)} $unit' : d.toStringAsFixed(0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
