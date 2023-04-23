import 'package:flutter/material.dart';

class MyAppBar extends AppBar {
  MyAppBar({super.key, required this.titleText, this.actionList});
  final String titleText;
  final List<Widget>? actionList;

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text(widget.titleText),
      actions: widget.actionList,
    );
  }
}
