import 'package:attendance/api/cloud/office_location.dart';
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:attendance/api/cloud/storage_exceptions.dart';
import 'package:attendance/utils/determine_position.dart';
import 'package:attendance/helpers/popup_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  final _cloudService = FirebaseStorage();
  late bool updating = false;

  void setUpdatState(bool newValeu) {
    setState(() => updating = newValeu);
  }

  Future<bool> _overrideBack() async {
    if (!updating) return true;
    setState(() => updating = false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _overrideBack,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Location"),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: FutureBuilder(
            future: _cloudService.getLocation,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    final location = snapshot.data;
                    if (updating) {
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
              TextButton.icon(
                onPressed: () => setUpdatState(true),
                icon: const Icon(Icons.edit),
                label: const Text("Change the office location."),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class AddLocation extends StatefulWidget {
  const AddLocation({required this.setNotify, this.location, super.key});
  final OfficeLocation? location;
  final ValueChanged<bool> setNotify;

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  final _cloudService = FirebaseStorage();
  final _name = TextEditingController();
  final _distance = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _disErroText;
  String? _nameErroText;
  String? _id;

  @override
  void initState() {
    super.initState();
    final location = widget.location;
    if (location != null) {
      _id = location.id;
      _name.text = location.officeName;
      _distance.text = location.distance.toString();
      setState(() {
        _longitude = location.longitude;
        _latitude = location.latitude;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _distance.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    LoadingScreen().show(context: context, text: "Submitting...");
    if (_distance.text.isEmpty || _distance.text == "") {
      setState(() => _disErroText = "Distance is required");
    }

    if (_name.text.isEmpty || _name.text == "") {
      setState(() => _nameErroText = "Name is required");
    }
    String? successMessage;
    try {
      if (_id == null) {
        await _cloudService.addLocation(
          officeName: _name.text,
          distance: double.parse(_distance.text),
          latitude: _latitude!,
          longitude: _longitude!,
        );
        successMessage = "Location information registerd successfully.";
      } else {
        await _cloudService.updateLocation(
          id: _id!,
          officeName: _name.text,
          distance: double.parse(_distance.text),
          latitude: _latitude!,
          longitude: _longitude!,
        );
        successMessage = "Location information update successfully.";
      }
    } on PermissionDeniedException catch (_) {
      showErorr(context, "Permission denied.");
    } on CouldNotUpdateException catch (_) {
      showErorr(context, "Could not update.");
    } on CouldNotCreateException catch (_) {
    } on AlreadyCreatedException catch (_) {
      showErorr(context, "Location already created.");
    } finally {
      if (successMessage != null) showSuccess(context, successMessage);
      widget.setNotify(false);
    }
    LoadingScreen().hide();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "Provide office location information",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: TextField(
            controller: _name,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              label: const Text("Office Address Name"),
              errorText: _nameErroText,
            ),
            onChanged: (value) {
              if (_disErroText != null) {
                setState(() => _nameErroText = null);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 18),
          child: TextField(
            controller: _distance,
            decoration: InputDecoration(
              label: const Text("Enter distance in meter"),
              errorText: _disErroText,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (value) {
              if (_disErroText != null) {
                setState(() => _disErroText = null);
              }
            },
          ),
        ),
        Row(
          children: [
            FloatingActionButton(
              elevation: 1,
              onPressed: () async {
                LoadingScreen()
                    .show(context: context, text: "Wait a moment...");
                try {
                  final position = await getCurrentPosition();
                  setState(() {
                    _latitude = position.latitude;
                    _longitude = position.longitude;
                  });
                } catch (e) {
                  showErorr(context, e.toString());
                }
                LoadingScreen().hide();
              },
              child: const Icon(Icons.location_pin),
            ),
            Container(
              padding: const EdgeInsets.only(left: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Latitude: ${_latitude.toString()}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Longitude: ${_longitude.toString()}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OutlinedButton(
            onPressed: _latitude == null ? null : _handleSubmit,
            child: Text(
              _id == null ? "Submit" : "Update",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        )
      ],
    );
  }
}
