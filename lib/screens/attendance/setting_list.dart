import 'package:attendance/extensions/strings.dart';
import 'package:attendance/api/cloud/setting.dart';
import 'package:flutter/material.dart';

class ListSetting extends StatelessWidget {
  const ListSetting({required this.setNotify, this.timestamp, super.key});
  final Setting? timestamp;
  final ValueChanged<bool> setNotify;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          const Text(
            'Attendance Timestamp',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 57,
              vertical: 16,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attendance begins at',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(timestamp!.startTime.toTime.format(context)),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Late time begins after',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(timestamp!.lateTime.toTime.format(context)),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attendance end after',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(timestamp!.endTime.toTime.format(context)),
                  ],
                )
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => setNotify(true),
            icon: const Icon(Icons.edit),
            label: const Text("Change the attendance time."),
          )
        ],
      ),
    );
  }
}
