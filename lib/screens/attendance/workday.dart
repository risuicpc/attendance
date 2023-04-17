import 'package:attendance/screens/attendance/workday_list.dart';
import 'package:attendance/utils/cloud/firebase_storage.dart';
import 'package:attendance/utils/cloud/user_workday.dart';
import 'package:flutter/material.dart';

class Workday extends StatefulWidget {
  const Workday({super.key});

  @override
  State<Workday> createState() => _WorkdayState();
}

class _WorkdayState extends State<Workday> {
  final _cloudService = FirebaseStorage();
  late bool _permission = false;
  late int _step = 1;

  void setPermission(id, userId) async {
    final perm =
        await _cloudService.isPermissionAllowToUpdate(id: id, userId: userId);
    setState(() => _permission = perm);
    _step--;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workday"),
      ),
      body: StreamBuilder<Object>(
          stream: _cloudService.allUserWorkday,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allUserWorkday = snapshot.data as Iterable<UserWorkday>;
                  if (allUserWorkday.isNotEmpty && _step > 0) {
                    setPermission(
                      allUserWorkday.elementAt(0).id,
                      allUserWorkday.elementAt(0).userId,
                    );
                  }

                  return WorkdayList(
                    allWorkday: allUserWorkday,
                    permission: _permission,
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
