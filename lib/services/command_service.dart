import 'package:cloud_functions/cloud_functions.dart';

class CommandService {
  final _functions = FirebaseFunctions.instance;

  Future<String> requestCommand({required String deviceId, required String type}) async {
    final callable = _functions.httpsCallable('requestCommand');
    final res = await callable.call({
      'deviceId': deviceId,
      'type': type,
    });
    final data = res.data as Map<dynamic, dynamic>;
    return (data['cmdId'] ?? '').toString();
  }
}
