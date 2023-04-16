import 'dart:developer';

import 'package:attendance/constants/routes.dart';
import 'package:attendance/enums/menu_action.dart';
import 'package:attendance/helpers/dialogs/logot_dialog.dart';
import 'package:attendance/utils/auth/bloc/block.dart';
import 'package:attendance/utils/auth/bloc/event.dart';
import 'package:attendance/utils/auth/firebase_provider.dart';
import 'package:attendance/utils/auth/user.dart';
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
  AuthUser get user => FirebaseAuthProvider().currentUser!;
  final _cloudService = FirebaseStorage();

  Future<void> _submitAttendance() async {
    log("id => ${user.id}");
    // final userIfo = await _cloudService.getUserInfo(userId: user.id);
    // log("name => ${userIfo?.userName}");
    // log("absent => ${userIfo?.numberOfAbsent}");
    // log("late => ${userIfo?.numberOfLate}");
    // if (userIfo != null) {
    //   await _cloudService.updateUserInfo(
    //       id: userIfo.id,
    //       numberOfLate: userIfo.numberOfLate - 1,
    //       numberOfAbsent: userIfo.numberOfAbsent - 3);
    // }
  }

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
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.workday,
                  child: Text("Workday"),
                ),
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.setting,
                  child: Text("Setting"),
                ),
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Logout"),
                ),
              ];
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
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Absent',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Late',
                              style: TextStyle(
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _submitAttendance,
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
