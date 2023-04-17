import 'package:attendance/constants/cloud_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class Setting {
  final String id;
  final bool updating;
  final DateTime lastUpdate;
  final String startTime;
  final String lateTime;
  final String endTime;

  const Setting({
    required this.id,
    required this.lastUpdate,
    required this.updating,
    required this.startTime,
    required this.lateTime,
    required this.endTime,
  });

  Setting.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        lastUpdate = snapshot.data()[lastUpdateFieldName].toDate(),
        updating = snapshot.data()[updatingFieldName],
        startTime = snapshot.data()[startTimeFieldName],
        lateTime = snapshot.data()[lateTimeFieldName],
        endTime = snapshot.data()[endTimeFieldName];
}
