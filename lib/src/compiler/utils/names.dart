import 'package:piko/src/compiler/utils/patterns.dart';

final RegExp voidElementNames =
    compile(r'^(?:area|base|br|col|command|embed|hr|img|input|keygen|link|meta|param|source|track|wbr)$');

bool isVoid(String name) {
  return voidElementNames.hasMatch(name) || name.toLowerCase() == '!doctype';
}
