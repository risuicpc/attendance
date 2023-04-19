import 'package:attendance/constants/cloud_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class Setting {
  final String id;
  final String startTime;
  final String lateTime;
  final String endTime;

  const Setting({
    required this.id,
    required this.startTime,
    required this.lateTime,
    required this.endTime,
  });

  Setting.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        startTime = snapshot.data()[startTimeFieldName],
        lateTime = snapshot.data()[lateTimeFieldName],
        endTime = snapshot.data()[endTimeFieldName];
}
