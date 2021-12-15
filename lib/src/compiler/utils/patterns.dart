late final RegExp whitespace = compile(r'[ \t\r\n]');

late final RegExp identifier = compile(r'[A-Za-z][A-Za-z0-9]*');

RegExp compile(String pattern) {
  return RegExp(pattern);
}
