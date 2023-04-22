import 'package:attendance/constants/cloud_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class Attendace {
  final String id;
  final String userId;
  final DateTime day;
  final String status;

  const Attendace({
    required this.id,
    required this.userId,
    required this.day,
    required this.status,
  });

  Attendace.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()[userIdFieldName],
        day = snapshot.data()[dayFieldName].toDate(),
        status = snapshot.data()[statusFieldName];
}
