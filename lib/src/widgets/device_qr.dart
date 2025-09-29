import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DeviceQr extends StatelessWidget {
  final String deviceId;
  const DeviceQr({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    if (deviceId.isEmpty) {
      return const Text('No Device ID');
    }
    return QrImageView(
      data: deviceId,
      version: QrVersions.auto,
      size: 150.0,
      backgroundColor: Colors.white,
    );
  }
}
