import 'dart:async';

import 'package:attendance/api/auth/firebase_provider.dart';
import 'package:attendance/api/auth/user.dart';
import 'package:attendance/api/cloud/atendance.dart';
import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:attendance/api/cloud/user_info.dart';
import 'package:attendance/constants/routes.dart';
import 'package:attendance/enums/action.dart' show MenuAction;
import 'package:attendance/extensions/date_time.dart';
import 'package:attendance/extensions/iterable.dart';
import 'package:attendance/helpers/dialogs/logot_dialog.dart';
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/helpers/popup_message.dart';
import 'package:attendance/utils/attendace_submitting.dart';
import 'package:attendance/utils/bloc/block.dart';
import 'package:attendance/utils/bloc/event.dart';
import 'package:attendance/utils/streaming.dart';
import 'package:attendance/widget/appbar.dart';
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
  UserInfo? _currentUserinfo;

  @override
  void initState() {
    _setSettingPermission();
    super.initState();
  }

  Future<void> _setSettingPermission() async {
    bool sp = await _cloudService.isSettingPermissionAllow;
    if (sp) {
      popupMenuItem.insert(
          1,
          const PopupMenuItem<MenuAction>(
            value: MenuAction.setting,
            child: Text("Setting"),
          ));
    }
  }

  Future<void> _setThisUser(Iterable<UserInfo> allInfo) async {
    _currentUserinfo = allInfo.firstWhereOrNull((e) => e.userId == _user.id);
    if (_currentUserinfo == null) {
      try {
        await _cloudService.createUserInfo(
          userId: _user.id,
          userName: _user.name ?? "No name",
        );
        _currentUserinfo = await _cloudService.getUserInfo(userId: _user.id);
      } catch (_) {}
    }
  }

  Iterable<UserInfo> _setLastAttend(
    Iterable<UserInfo> allInfo,
    List<Attendace> allAttend,
  ) {
    allAttend.sort((a, b) => b.day.compareTo(a.day));
    List<UserInfo> updateUserInfo = [];
    for (UserInfo userInfo in allInfo) {
      userInfo.lastAttend =
          allAttend.firstWhereOrNull((e) => e.userId == userInfo.userId)?.day;
      updateUserInfo.add(userInfo);
    }

    return updateUserInfo;
  }

  void _handleSubmit() async {
    String? successMsg;
    try {
      await attendanceSubmitting(context, _currentUserinfo);
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

  String attendText(DateTime? lastAttend) {
    return lastAttend == null ? "Not yet" : lastAttend.toWord;
  }

  Color attendColor(DateTime? lastAttend) {
    if (lastAttend == null) return const Color.fromARGB(193, 0, 0, 0);
    if (lastAttend.toWord == "Today") return Colors.greenAccent.shade700;
    if (lastAttend.toWord == "Yesterday") return Colors.greenAccent.shade700;
    return Colors.amber.shade700;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [
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
          }
        },
        itemBuilder: (context) {
          return popupMenuItem;
        },
      )
    ];

    return Scaffold(
      appBar: MyAppBar(titleText: "Attendance", actionList: actions),
      body: StreamBuilder(
          stream: _cloudService.allUserInfo,
          builder: (context, snapshot1) {
            switch (snapshot1.connectionState) {
              case ConnectionState.active:
                if (snapshot1.hasData) {
                  Iterable<UserInfo> allUserInfo =
                      snapshot1.data as Iterable<UserInfo>;
                  _setThisUser(allUserInfo);

                  return StreamBuilder(
                      stream: _cloudService.getAllAttendace,
                      builder: (context, snapshot2) {
                        switch (snapshot2.connectionState) {
                          case ConnectionState.active:
                            if (snapshot2.hasData) {
                              Iterable<Attendace> allAttend =
                                  snapshot2.data as Iterable<Attendace>;
                              allUserInfo = _setLastAttend(
                                allUserInfo,
                                allAttend.toList(),
                              );
                              return ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 32),
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
                                  Table(
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      columnWidths: const {
                                        1: FixedColumnWidth(100),
                                        2: FixedColumnWidth(65),
                                        3: FixedColumnWidth(50),
                                      },
                                      border: TableBorder(
                                        horizontalInside: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 0.5),
                                      ),
                                      children: [
                                        const TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 25.0,
                                                top: 20,
                                                bottom: 10),
                                            child: Text(
                                              "Name",
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Attend",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Absent",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Late",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ]),
                                        for (var userInfo in allUserInfo)
                                          TableRow(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 25,
                                                top: 10,
                                                bottom: 10,
                                              ),
                                              child: Text(
                                                userInfo.userName,
                                                style: const TextStyle(
                                                  fontSize: 15.0,
                                                  color: Color.fromARGB(
                                                      193, 0, 0, 0),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              attendText(userInfo.lastAttend),
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                color: attendColor(
                                                    userInfo.lastAttend),
                                              ),
                                            ),
                                            Text(
                                              userInfo.numberOfAbsent
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 15.0),
                                            ),
                                            Text(
                                              userInfo.numberOfLate.toString(),
                                              style: const TextStyle(
                                                  fontSize: 15.0),
                                            ),
                                          ]),
                                      ]),
                                  Container(
                                    height: 110,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 32,
                                    ),
                                    child: StreamBuilder<bool>(
                                      stream: getAttendancePermission(true),
                                      builder: (context, snapshot3) {
                                        switch (snapshot3.connectionState) {
                                          case ConnectionState.active:
                                            if (snapshot3.hasData &&
                                                snapshot3.data == true) {
                                              return ElevatedButton(
                                                onPressed: _handleSubmit,
                                                child: const Text(
                                                    "Submit Attendance"),
                                              );
                                            } else {
                                              return const ElevatedButton(
                                                onPressed: null,
                                                child:
                                                    Text("Submit Attendance"),
                                              );
                                            }
                                          default:
                                            return ElevatedButton(
                                              onPressed: () {},
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                color: Colors.white,
                                              )),
                                            );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return const Center(
                                  child: Text(
                                      "Registered employee is not available."));
                            }
                          default:
                            return const Text("");
                        }
                      });
                } else {
                  return const Center(
                      child: Text("Registered employee is not available."));
                }
              default:
                return const Text("");
            }
          }),
    );
  }
}
