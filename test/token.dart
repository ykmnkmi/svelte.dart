import 'dart:mirrors';

import 'package:analyzer/dart/ast/token.dart';

void main() {
  var token = reflectClass(Token);
  print(token.location);
}