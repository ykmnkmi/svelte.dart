import 'dart:convert';

import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

const template = '''
<a href=https://www.google.com>Google</a>
''';

void main() {
  try {
    var json = parse(template).toJson();
    print(const JsonEncoder.withIndent('  ').convert(json));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
