import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final FirebaseDatabase db = FirebaseDatabase.instance;

  DatabaseReference liveRef(String deviceId) => db.ref('live/$deviceId');
  Query alertsQuery(String deviceId) => db.ref('devices/$deviceId/alerts').limitToLast(50);

  DatabaseReference aggregatesDaily(String deviceId, String ymd) =>
      db.ref('aggregates/daily/$deviceId/$ymd');

  Future<void> linkDeviceToUser({required String uid, required String deviceId}) async {
    final ref = db.ref('users/$uid/devices/$deviceId');
    await ref.set(true);
  }

  Future<void> unlinkDeviceFromUser({required String uid, required String deviceId}) async {
    final ref = db.ref('users/$uid/devices/$deviceId');
    await ref.remove();
  }
}
