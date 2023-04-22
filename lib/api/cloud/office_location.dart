import 'package:attendance/constants/cloud_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class OfficeLocation {
  final String id;
  final String officeName;
  final double latitude;
  final double longitude;
  final double distance;

  const OfficeLocation({
    required this.id,
    required this.officeName,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  OfficeLocation.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        officeName = snapshot.data()[officeNameFieldName],
        latitude = snapshot.data()[latitudeFieldName],
        longitude = snapshot.data()[longitudeFieldName],
        distance = snapshot.data()[distanceFieldName];
}
