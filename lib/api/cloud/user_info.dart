import 'package:attendance/constants/cloud_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
  final String id;
  final String userId;
  final String userName;
  final int numberOfLate;
  final int numberOfAbsent;
  final String deviceId;
  final String androidId;
  DateTime? lastAttend;

  UserInfo({
    required this.id,
    required this.userId,
    required this.userName,
    required this.numberOfLate,
    required this.numberOfAbsent,
    required this.deviceId,
    required this.androidId,
    this.lastAttend,
  });

  UserInfo.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()[userIdFieldName],
        userName = snapshot.data()[userNameFieldName] ?? "",
        numberOfLate = snapshot.data()[numberOfLateFieldName],
        numberOfAbsent = snapshot.data()[numberOfAbsentFieldName],
        deviceId = snapshot.data()[deviceIdFieldName],
        androidId = snapshot.data()[androidIdFieldName];
}
