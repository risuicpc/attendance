import 'package:attendance/api/cloud/calendar.dart';
import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/widget/appbar.dart';
import 'package:flutter/material.dart';

class CompanyCalendar extends StatefulWidget {
  const CompanyCalendar({super.key});

  @override
  State<CompanyCalendar> createState() => _CompanyCalendarState();
}

typedef MyCallback = void Function(int i, int j, int k);

class _CompanyCalendarState extends State<CompanyCalendar> {
  final _cloudService = FirebaseStorage();
  late List<List<List<Calendar>>> _calendar = [];
  final _headers = ["M", "T", "W", "T", "F", "S", "S"];
  final _months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF8FBF8EF),
      appBar: MyAppBar(titleText: "Calendar"),
      body: FutureBuilder(
        future: FirebaseStorage().listCalendar,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                _calendar = snapshot.data as List<List<List<Calendar>>>;
                LoadingScreen().hide();
              }
              break;
            default:
          }

          if (snapshot.hasError) {
            LoadingScreen().hide();
            return const Center(
              child: Text("An error occurred while fetching the calendar."),
            );
          }

          if (_calendar.isNotEmpty) {
            return ListView.builder(
              itemCount: _calendar.length,
              itemBuilder: (context, index) {
                final month = _calendar[index];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "${_months[index]} ${DateTime.now().year}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 1,
                            color: Color(0x4D090F13),
                            offset: Offset(0, 1),
                          )
                        ],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Table(
                        defaultColumnWidth: FixedColumnWidth(
                          (MediaQuery.of(context).size.width - 44) / 7,
                        ),
                        children: [
                          TableRow(children: [
                            for (String header in _headers)
                              headerContainer(header)
                          ]),
                          for (var week in month)
                            TableRow(
                              children: [
                                for (var day in week)
                                  if (day.id == "")
                                    const Text("")
                                  else if (day.workday)
                                    unstyledContainer(day)
                                  else
                                    styledContainer(day)
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget headerContainer(String name) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget styledContainer(Calendar day) {
    return GestureDetector(
      onDoubleTap: () async {
        LoadingScreen().show(context: context, text: "Updating...");
        try {
          await _cloudService.updateCalendar(
            id: day.id,
            workday: true,
          );
          setState(() {});
        } catch (_) {}
      },
      child: Container(
        height: 43,
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(7)),
        ),
        child: Text(
          day.date.day.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget unstyledContainer(
    Calendar day,
  ) {
    return GestureDetector(
      onDoubleTap: () async {
        LoadingScreen().show(context: context, text: "Updating...");
        try {
          await _cloudService.updateCalendar(
            id: day.id,
            workday: false,
          );
          setState(() {});
        } catch (_) {}
      },
      child: Container(
        height: 43,
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.all(4),
        child: Text(
          day.date.day.toString(),
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
