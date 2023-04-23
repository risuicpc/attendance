import 'package:attendance/screens/attendance/workday_list.dart';
import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:attendance/api/cloud/user_workday.dart';
import 'package:attendance/widget/appbar.dart';
import 'package:flutter/material.dart';

class Workday extends StatefulWidget {
  const Workday({super.key});

  @override
  State<Workday> createState() => _WorkdayState();
}

class _WorkdayState extends State<Workday> {
  final _cloudService = FirebaseStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(titleText: "Workday"),
      body: StreamBuilder(
          stream: _cloudService.allUserWorkday,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allUserWorkday = snapshot.data as Iterable<UserWorkday>;

                  if (allUserWorkday.isNotEmpty) {
                    return FutureBuilder<bool>(
                      future: _cloudService.isPermissionAllowToUpdate,
                      builder: (context, snapshot1) {
                        switch (snapshot1.connectionState) {
                          case ConnectionState.done:
                            if (snapshot1.hasData) {
                              return WorkdayList(
                                allWorkday: allUserWorkday,
                                permission: snapshot1.data ?? false,
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          default:
                            return const Center(
                                child: CircularProgressIndicator());
                        }
                      },
                    );
                  } else {
                    return const Center(child: Text("No data."));
                  }
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
