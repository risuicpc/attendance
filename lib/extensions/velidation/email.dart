extension EmailValidator on String {
  bool isValidEmail() {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    return RegExp(pattern).hasMatch(this);
  }

  bool isNotValidEmail() {
    return !isValidEmail();
  }

  bool isWhiteListedDomain() {
    return toLowerCase().endsWith("@toptech.et");
  }

  bool isNotWhiteListedDomain() {
    return !isWhiteListedDomain();
  }
}
