import 'package:ng/src/component.dart';

const String source = '''
var count = 0;

void handleClick() {
  count += 1;
}
''';

void main() {
  print(detect(source, prefix: 'context'));
}

// ignore_for_file: avoid_print
