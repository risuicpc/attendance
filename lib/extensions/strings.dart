extension StringExtension on String {
  String capitalize() {
    return split(' ')
        .map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}")
        .join(' ');
  }
}
