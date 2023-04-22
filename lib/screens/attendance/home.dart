import 'dart:async';

import 'package:attendance/constants/routes.dart';
import 'package:attendance/enums/action.dart' show MenuAction;
import 'package:attendance/extensions/iterable.dart';
import 'package:attendance/helpers/dialogs/logot_dialog.dart';
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/helpers/popup_message.dart';
import 'package:attendance/utils/auth/bloc/block.dart';
import 'package:attendance/utils/auth/bloc/event.dart';
import 'package:attendance/utils/auth/firebase_provider.dart';
import 'package:attendance/utils/auth/user.dart';
import 'package:attendance/utils/cloud/attendace_submitting.dart';
import 'package:attendance/utils/cloud/firebase_storage.dart';
import 'package:attendance/utils/cloud/user_info.dart';
import 'package:attendance/utils/streaming.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthUser get _user => FirebaseAuthProvider().currentUser!;
  final _cloudService = FirebaseStorage();
  final _header = ["Name", "Absent", "Late"];
  UserInfo? currentUserinfo;

  @override
  void initState() {
    _setSettingPermission();
    super.initState();
  }

  Future<void> _setSettingPermission() async {
    bool sp = await _cloudService.isSettingPermissionAllow;
    if (sp) {
      setState(() {
        popupMenuItem.insert(
            1,
            const PopupMenuItem<MenuAction>(
              value: MenuAction.setting,
              child: Text("Setting"),
            ));
      });
    }
  }

  Future<void> _setCurrentUserInfo(Iterable<UserInfo> allUserInfo) async {
    currentUserinfo = allUserInfo.firstWhereOrNull((e) => e.userId == _user.id);
    if (currentUserinfo != null) return;

    try {
      await _cloudService.createUserInfo(
        userId: _user.id,
        userName: _user.name!,
      );
      currentUserinfo = await _cloudService.getUserInfo(userId: _user.id);
    } catch (_) {}
    return;
  }

  void _handleSubmit() async {
    String? successMsg;
    try {
      await attendanceSubmitting(context, currentUserinfo);
      successMsg = "The attendance was submitted successfully.";
    } catch (e) {
      showErorr(context, e.toString());
    } finally {
      if (successMsg != null) showSuccess(context, successMsg);
      LoadingScreen().hide();
    }
  }

  var popupMenuItem = [
    const PopupMenuItem<MenuAction>(
      value: MenuAction.workday,
      child: Text("Workday"),
    ),
    const PopupMenuItem<MenuAction>(
      value: MenuAction.logout,
      child: Text("Logout"),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(locationRoute);
            },
            icon: const Icon(Icons.location_on),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              final read = context.read<AuthBloc>();
              switch (value) {
                case MenuAction.workday:
                  Navigator.of(context).pushNamed(workdayListRoute);
                  break;
                case MenuAction.setting:
                  Navigator.of(context).pushNamed(settingRoute);
                  break;
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    read.add(const AuthEventLogOut());
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return popupMenuItem;
            },
          )
        ],
      ),
      body: StreamBuilder(
          stream: _cloudService.allUserInfo,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allUserInfo = snapshot.data as Iterable<UserInfo>;
                  _setCurrentUserInfo(allUserInfo);
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    children: <Widget>[
                      const Center(
                        child: Text(
                          'Employee Attendance',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataTable(
                        columns: [
                          for (var label in _header)
                            DataColumn(
                              label: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                        rows: [
                          for (var userInfo in allUserInfo)
                            DataRow(cells: [
                              DataCell(Text(userInfo.userName)),
                              DataCell(
                                Text(userInfo.numberOfAbsent.toString()),
                              ),
                              DataCell(Text(userInfo.numberOfLate.toString())),
                            ]),
                        ],
                      ),
                      Container(
                        height: 110,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 32,
                        ),
                        child: StreamBuilder<bool>(
                          stream: getAttendancePermission(true),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.active:
                              case ConnectionState.done:
                                if (snapshot.hasData) {
                                  return ElevatedButton(
                                    onPressed: snapshot.data ?? false
                                        ? _handleSubmit
                                        : null,
                                    child: const Text("Submit Attendance"),
                                  );
                                } else {
                                  return const ElevatedButton(
                                    onPressed: null,
                                    child: Text("Submit Attendance"),
                                  );
                                }
                              default:
                                return const ElevatedButton(
                                  onPressed: null,
                                  child: Text("Submit Attendance"),
                                );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              default:
                return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
