import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

const String template = 'Hello { name }!';

void main() {
  try {
    print(parse(template));
  } catch (error, trace) {
    print(error);
    print(Trace.format(trace, terse: true));
  }
}

// ignore_for_file: avoid_print
