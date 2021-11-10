late final RegExp whitespace = compile(r'[ \t\r\n]');

RegExp compile(String pattern) {
  return RegExp(pattern);
}
