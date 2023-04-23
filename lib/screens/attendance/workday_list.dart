import 'package:attendance/constants/routes.dart';
import 'package:attendance/api/cloud/user_workday.dart';
import 'package:flutter/material.dart';

class WorkdayList extends StatelessWidget {
  const WorkdayList({
    required this.allWorkday,
    required this.permission,
    super.key,
  });
  final Iterable<UserWorkday> allWorkday;
  final bool permission;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allWorkday.length,
      itemBuilder: (context, index) {
        final workday = allWorkday.elementAt(index);

        return Column(
          children: <Widget>[
            TextButton(
              onPressed: permission
                  ? () {
                      Navigator.of(context).pushNamed(
                        workdayEditRoute,
                        arguments: workday,
                      );
                    }
                  : null,
              child: Text(
                workday.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 80.0,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, ind) {
                  return GestureDetector(
                    child: Card(
                      color: const Color.fromARGB(244, 255, 255, 255),
                      elevation: 1.0,
                      child: Container(
                        height: MediaQuery.of(context).size.width / 3,
                        width: MediaQuery.of(context).size.width / 3.5,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            if (ind == 0) dataColumn("Mon", workday.monday),
                            if (ind == 1) dataColumn("Tue", workday.tuesday),
                            if (ind == 2) dataColumn("Wed", workday.wednesday),
                            if (ind == 0) dataColumn("Thu", workday.thursday),
                            if (ind == 1) dataColumn("Fri", workday.friday),
                            if (ind == 2) dataColumn("Sat", workday.saturday),
                            if (ind == 0) dataColumn("Sun", workday.sunday),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Row dataColumn(String title, bool day) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(title),
        Icon(
          day ? Icons.work : Icons.home_work,
          color: day ? Colors.amber.shade700 : Colors.blueGrey,
        ),
      ],
    );
  }
}
