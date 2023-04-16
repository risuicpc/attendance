import 'package:attendance/constants/cloud_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show QueryDocumentSnapshot;
import 'package:flutter/foundation.dart' show immutable;

@immutable
class UserWorkday {
  final String id;
  final String userId;
  final String userName;
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;

  const UserWorkday({
    required this.id,
    required this.userId,
    required this.userName,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  UserWorkday.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()[userIdFieldName],
        userName = snapshot.data()[userNameFieldName] ?? "",
        monday = snapshot.data()[mondayFieldName],
        tuesday = snapshot.data()[tuesdayFieldName],
        wednesday = snapshot.data()[wednesdayFieldName],
        thursday = snapshot.data()[thursdayFieldName],
        friday = snapshot.data()[fridayFieldName],
        saturday = snapshot.data()[saturdayFieldName],
        sunday = snapshot.data()[sundayFieldName];
}
