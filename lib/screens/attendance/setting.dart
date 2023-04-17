import 'package:attendance/screens/attendance/add_setting.dart';
import 'package:attendance/screens/attendance/list_setting.dart';
import 'package:attendance/utils/cloud/firebase_storage.dart';
import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
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
          title: const Text("Settings"),
        ),
        body: FutureBuilder(
          future: _cloudService.getSetting,
          builder: (BuildContext context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasData) {
                  final timestamp = snapshot.data;
                  if (updating) {
                    return AddSatting(
                      setting: timestamp,
                      setNotify: setUpdatState,
                    );
                  }
                  return ListSetting(
                    timestamp: timestamp,
                    setNotify: setUpdatState,
                  );
                } else {
                  return AddSatting(setNotify: setUpdatState);
                }
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ),
      ),
    );
  }
}
