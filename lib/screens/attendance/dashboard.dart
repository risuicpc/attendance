import 'package:attendance/constants/routes.dart';
import 'package:attendance/enums/menu_action.dart';
import 'package:attendance/helpers/dialogs/logot_dialog.dart';
import 'package:attendance/utils/cloud/submit_button.dart';
import 'package:attendance/utils/auth/bloc/block.dart';
import 'package:attendance/utils/auth/bloc/event.dart';
import 'package:attendance/utils/cloud/firebase_storage.dart';
import 'package:attendance/utils/cloud/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final _cloudService = FirebaseStorage();
  final List<String> _header = ["Name", "Absent", "Late"];

  @override
  void initState() {
    setSettingPermission();
    super.initState();
  }

  Future<void> setSettingPermission() async {
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
                        child: ElevatedButton(
                          onPressed: () {
                            submitAttendance(context, allUserInfo);
                          },
                          child: const Text("Submit Attendance"),
                        ),
                      )
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
