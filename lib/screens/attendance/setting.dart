import 'package:attendance/screens/attendance/setting_add.dart';
import 'package:attendance/screens/attendance/setting_list.dart';
import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
