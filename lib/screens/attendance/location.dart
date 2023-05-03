import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:attendance/api/cloud/office_location.dart';
import 'package:attendance/screens/attendance/location_add.dart';
import 'package:attendance/widget/appbar.dart';
import 'package:flutter/material.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  final _cloudService = FirebaseStorage();
  late bool _updating = false;
  late bool _editPermissionAllow = false;

  @override
  void initState() {
    super.initState();
    setPermission();
  }

  Future<void> setPermission() async {
    _editPermissionAllow = await _cloudService.isLocationPermissionAllow;
    setState(() {});
  }

  void setUpdatState(bool newValeu) {
    _updating = newValeu;
    setState(() {});
  }

  Future<bool> _overrideBack() async {
    if (!_updating) return true;
    setState(() => _updating = false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _overrideBack,
      child: Scaffold(
        appBar: MyAppBar(titleText: "Location"),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: FutureBuilder(
            future: _cloudService.getLocation,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    final location = snapshot.data;
                    if (_updating) {
                      return AddLocation(
                        setNotify: setUpdatState,
                        location: location,
                      );
                    } else {
                      return displayLocation(location);
                    }
                  } else {
                    return AddLocation(setNotify: setUpdatState);
                  }
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  Widget displayLocation(OfficeLocation? location) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Text(
                "This is a '${location?.officeName}' location map that is showing (${location?.latitude.toString()}, ${location?.longitude.toString()}).",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "To provide presence, the distance from the office is allowed up to ${location?.distance} meters",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _editPermissionAllow
                  ? TextButton.icon(
                      onPressed: () => setUpdatState(true),
                      icon: const Icon(Icons.edit_location_alt),
                      label: const Text("Change the office location."),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ],
    );
  }
}
